' WebSocketClient.brs
' Copyright (C) 2018 Rolando Islas
' Released under the MIT license
'
' Utilities for operating with the Transport Layer Security (TLS) protocol
' Follows RFC 5246

' TlsUtil object
' Requires pkg:/components/web_socket_client/Logger.brs
' Requires pkg:/components/web_socket_client/ByteUtil.brs
' @param socket roStreamSocket async TCP socket
function TlsUtil(socket = invalid as object) as object
    tls_util = {}
    ' Constants
    tls_util.STATE_DISCONNECTED = 0
    tls_util.STATE_CONNECTING = 1
    tls_util.STATE_FINISHED = 2
    tls_util._BUFFER_SIZE = cint(1024 * 1024 * 1)
    tls_util._TLS_VERSION = [3, 3]
    ' TLS Constants
    tls_util._TLS_FRAGMENT_MAX_LENGTH = 2^14
    tls_util._HANDSHAKE_TYPE = {
        HELLO_REQUEST: 0,
        CLIENT_HELLO: 1,
        SERVER_HELLO: 2,
        CERTIFICATE: 11,
        SERVER_KEY_EXCHANGE: 12,
        CERTIFICATE_REQUEST: 13,
        SERVER_HELLO_DONE: 14,
        CERTIFICATE_VERIFY: 15,
        CLIENT_KEY_EXCHANGE: 16,
        FINISHED: 20
    }
    tls_util._RECORD_TYPE = {
        CHANGE_CIPHER_SPEC: 20,
        ALERT: 21,
        HANDSHAKE: 22,
        APPLICATION_DATA: 23
    }
    tls_util._EXTENSION_TYPE = {
        SERVER_NAME: 0,
        SUPPORTED_GROUPS: 10,
        EC_POINT_FORMATS: 11
    }
    tls_util._ALERT_LEVEL = {
        WARNING: 1
        FATAL: 2
    }
    tls_util._ALERT_TYPE = {
        CLOSE_NOTIFY: 0,
        UNEXPECTED_MESSAGE: 10,
        HANDSHAKE_FAILURE: 40,
        BAD_CERTIFICATE: 42,
        PROTOCOL_VERSION: 70,
        UNSUPPORTED_EXTENSION: 110
    }
    tls_util._COMPRESSION_METHODS = {
        NULL: 0
    }
    tls_util._SUPPORTED_GROUPS = {
        SECP256R1: 23,
        SECP384R1: 24,
        SECP521R1: 25
    }
    tls_util._EC_POINT_FORMATS = {
        UNCOMPRESSED: 0
    }
    ' Variables
    tls_util._data = createObject("roByteArray")
    tls_util._data[tls_util._BUFFER_SIZE] = 0
    tls_util._data_size = 0
    tls_util.ready_state = tls_util.STATE_DISCONNECTED
    tls_util._socket = socket
    tls_util._hostname = invalid
    tls_util._client_hello_random = invalid
    tls_util._server_hello_random = invalid
    tls_util._cipher_suite = invalid
    tls_util._handshake_buffer = createObject("roByteArray")
    tls_util._supported_extensions = []
    tls_util._handshake_start_time = 0
    tls_util._certificates = []
    tls_util._server_public_key = invalid
    
    ' Decode TLS bytes
    ' This function buffers data if it does not have enough bytes to decode
    ' @param self TlsUtil object referring to the TlsObject to operate on,
    '                     usually itself
    ' @param input roByteArray
    ' @param size integer size of usable data in the input array starting from
    '                     index 0
    ' @return roByteArray of decoded data. The returned array may have a count
    '         of zero. May return invalid on error
    tls_util.read = function (self as object, input as object, size as integer) as object
        if self.ready_state = self.STATE_DISCONNECTED
            printl("DEBUG", "TlsUtil: Read failed: state is disconnected")
            return invalid
        end if
        if self._has_handshake_timed_out(self)
            printl("DEBUG", "TlsUtil: Handshake timed out")
            return invalid
        end if
        decoded_app_data = createObject("roByteArray")
        ' TLS Record Frame
        if size >= 0
            ' Save to buffer
            for byte_index = self._data_size to self._data_size + size - 1
                self._data[byte_index] = input[byte_index - self._data_size]
            end for
            self._data_size += size
            input = invalid
            ' Wait for frame size
            fragment_start_index = 5
            if self._data_size < fragment_start_index
                return decoded_app_data
            end if
            ' Record
            content_type = self._data[0]
            version_major = self._data[1]
            version_minor = self._data[2]
            fragment_length = bytes_to_short(self._data[3], self._data[4])
            ' Check version
            if self._TLS_VERSION[0] <> version_major or self._TLS_VERSION[1] <> version_minor
                self._error(self, self._ALERT_TYPE.PROTOCOL_VERSION, "Received a frame with an an unsupported version defined")
                return invalid
            end if
            ' Wait for fragment
            if self._data_size < fragment_start_index + fragment_length
                return decoded_app_data
            end if
            ' Fragment
            fragment = createObject("roByteArray")
            for byte_index = fragment_start_index to fragment_start_index + fragment_length - 1
                fragment.push(self._data[byte_index])
            end for
            handled_fragment = self._handle_fragment(self, content_type, fragment)
            if handled_fragment = invalid
                return invalid
            else
                decoded_app_data.append(handled_fragment)
            end if
            ' Delete fragment from buffer
            self._data = byte_array_sub(self._data, fragment_start_index + fragment_length, self._data_size - 1)
            self._data_size = self._data.count()
            self._data[self._BUFFER_SIZE] = 0
        end if
        return decoded_app_data
    end function
    
    ' Check if the handshake has timed out
    ' @param TlsUtil
    ' @return if the handshake has not completed before a timed out
    tls_util._has_handshake_timed_out = function (self as object) as boolean
        return uptime(0) - self._handshake_start_time >= 30 and self._handshake_start_time > -1
    end function
    
    ' Send a fatal alert and optionally log a debug message and set the state to disconnected if fatal
    ' @param self TlsUtil
    ' @param alert_type integer type
    ' @param message string optional message to log
    ' @param fatal boolean set the alert type to fatal and disconnect
    tls_util._error = function (self as object, alert_type as integer, message = "" as string, fatal = true as boolean) as void
        level = self._ALERT_LEVEL.FATAL
        if not fatal
            level = self._ALERT_LEVEL.WARNING
        end if
        self._send_alert(self, level, alert_type)
        if message <> ""
            printl("DEBUG", "TlsUtil: Error: " + message)
        end if
        if fatal
            self.ready_state = self.STATE_DICONNECTED
        end if
    end function
    
    ' Send an alert
    ' @param self TlsUtil
    ' @param alert_level integer level of alert
    ' @param alert_type integer alert description
    tls_util._send_alert = function (self as object, alert_level as integer, alert_type as integer)
        alert = createObject("roByteArray")
        alert.push(alert_level)
        alert.push(alert_type)
        self._send_record(self, self._RECORD_TYPE.ALERT, alert)
    end function
    
    ' Handle opaque fragment data
    ' @param self TlsUtil
    ' @param content_type type of frame
    ' @param frame roByteArray frame
    ' @return potentially empty roByteArray or invalid on error. disconnect state is handled on error
    tls_util._handle_fragment = function (self as object, content_type as integer, fragment as object) as object
        'printl("VERBOSE", "TlsUtil: Received fragment of type " + content_type.toStr() + ": " + fragment.toHexString())
        ? "TlsUtil: Received fragment of type " + content_type.toStr() + ": " + fragment.toHexString()
        decoded_app_data = createObject("roByteArray")
        while fragment.count() > 0
            ' Handshake
            if content_type = self._RECORD_TYPE.HANDSHAKE
                fragment_header_size = 4
                ' Invalid data
                if fragment.count() < fragment_header_size
                    self._error_handshake(self)
                    return invalid
                ' Handle handshake data
                else
                    handshake_type = fragment[0]
                    length = bytes_to_int24(fragment[1], fragment[2], fragment[3])
                    if fragment.count() < fragment_header_size + length
                        self._error_handshake(self)
                        return invalid
                    end if
                    handshake_data = createObject("roByteArray")
                    for byte_index = fragment_header_size to fragment_header_size + length - 1
                        handshake_data.push(fragment[byte_index])
                    end for
                    if not self._handle_handshake(self, handshake_type, handshake_data)
                        return invalid
                    end if
                    self._handshake_buffer.append(byte_array_sub(fragment, 0, fragment_header_size + length - 1))
                    fragment = byte_array_sub(fragment, fragment_header_size + length, fragment.count() - 1)
                end if
            ' App data
            else if content_type = self._RECORD_TYPE.APPLICATION_DATA
            ' Alert
            else if content_type = self._RECORD_TYPE.ALERT
                if fragment.count() < 2
                    self._error_handshake(self)
                    return invalid
                else
                    alert_level = fragment[0]
                    alert_description = fragment[1]
                    printl("DEBUG", "TlsUtil: Received alert:")
                    printl("DEBUG", "  level: " + alert_level.toStr())
                    printl("DEBUG", "  description: " + alert_description.toStr())
                    if alert_level = self._ALERT_LEVEL.FATAL
                        self._error(self, self._ALERT_TYPE.CLOSE_NOTIFY, "Received fatal alert", true)
                        return invalid
                    end if
                    fragment = byte_array_sub(fragment, 2, fragment.count() - 1)
                end if
            ' Cipher spec
            else if content_type = self._CHANGE_CIPHER_SPEC
                
            end if
        end while
        return decoded_app_data
    end function
    
    ' Handle handshake data
    ' @param self TlsUtil
    ' @param handshake_type integer type of handshake data
    ' @param handshake roByteArray handshake data
    ' @return false on error
    tls_util._handle_handshake = function (self as object, handshake_type as integer, handshake as object) as boolean
        ' HelloRequest
        if handshake_type = self._HANDSHAKE_TYPE.HELLO_REQUEST
            if self.ready_state = self.STATE_DISCONNECTED
                self.connect(self, self._hostname)
            end if
        ' ServerHello
        else if handshake_type = self._HANDSHAKE_TYPE.SERVER_HELLO
            if handshake.count() < 38
                self._error_handshake(self)
                return false
            end if
            version_major = handshake[0]
            version_minor = handshake[1]
            if version_major <> self._tls_version[0] or version_minor <> self._tls_version[1]
                self._error_handshake(self)
                return false
            end if
            random_time = bytes_to_int(handshake[2], handshake[3], handshake[4], handshake[5])
            random = createObject("roByteArray")
            for byte_index = 6 to 33
                random.push(handshake[byte_index])
            end for
            self._server_hello_random = random
            session_id = createObject("roByteArray")
            session_id_length = handshake[34]
            for byte_index = 35 to 34 + session_id_length
                session_id.push(handshake[byte_index])
            end for
            cipher_suite = createObject("roByteArray")
            cipher_suite.push(handshake[35 + session_id_length])
            cipher_suite.push(handshake[36 + session_id_length])
            self._cipher_suite = cipher_suite
            compression_method = handshake[37 + session_id_length]
            if compression_method <> self._COMPRESSION_METHODS.NULL
                self._error_handshake(self)
                return false
            end if
            extensions = createObject("roByteArray")
            if handshake.count() > 38 + session_id_length
                extensions_length = bytes_to_short(handshake[38 + session_id_length], handshake[39 + session_id_length])
                for byte_index = 40 + session_id_length to 39 + session_id_length + extensions_length
                    extensions.push(handshake[byte_index])
                end for
            end if
            extension_types = []
            if extensions.count() > 0
                extension_index = 0
                while extension_index < extensions.count()
                    if extensions.count() - extension_index < 4
                        self._error_handshake(self)
                        return false
                    end if
                    extension_type = bytes_to_short(extensions[extension_index], extensions[extension_index + 1])
                    extension_length = bytes_to_short(extensions[extension_index + 2], extensions[extension_index + 3])
                    extension_index += 4 + extension_length
                    extension_types.push(extension_type)
                end while
            end if
            for each extension_type in extension_types
                ' Check if extension was requested
                was_extension_requested = false
                for each supported_extension in self._supported_extensions
                    if supported_extension = extension_type
                        was_extension_requested = true
                    end if
                end for
                if not was_extension_requested
                    self._error(self, self._ALERT_TYPE.UNSUPPORTED_EXTENSION, "Received invalid extension data", true)
                    return false
                end if
                ' Check if extension has been defined more than once
                extension_definitions = 0
                for each extension_type_loop in extension_types
                    if extension_type = extension_type_loop
                        extension_definitions++
                        if extension_definitions > 1
                            self._error(self, self._ALERT_TYPE.UNSUPPORTED_EXTENSION, "Received invalid extension data", true)
                            return false
                        end if
                    end if
                end for
            end for
            'printl("DEBUG", "TlsUtil: Received ServerHello:")
            ? "TlsUtil: Received ServerHello:"
            'printl("DEBUG", "  cipher suite: " + cipher_suite.toHexString())
            ?   "cipher suite: " + cipher_suite.toHexString()
        ' Certificate
        else if handshake_type = self._HANDSHAKE_TYPE.CERTIFICATE
            certificate_list = []
            if handshake.count() < 3
                self._error_handshake(self)
                return false
            end if
            certificate_list_length = bytes_to_int24(handshake[0], handshake[1], handshake[2])
            if handshake.count() < 3 + certificate_list_length
                self._error_handshake(self)
                return false
            end if
            certificate_index = 3
            while certificate_index + 1 < handshake.count()
                certificate_size = bytes_to_int24(handshake[certificate_index], handshake[certificate_index + 1], handshake[certificate_index + 2])
                if handshake.count() < certificate_index + certificate_size
                    self._error_handshake(self)
                    return false
                end if
                certificate = createObject("roByteArray")
                for byte_index = certificate_index + 3 to certificate_index + certificate_size - 1
                    certificate.push(handshake[byte_index])
                end for
                certificate_list.push(certificate)
                certificate_index += 3 + certificate_size
            end while
            self._certificates = certificate_list
            'printl("DEBUG", "TlsUtil: Received Certificate: " + certificate_list.count().toStr() + " certificates")
            ? "TlsUtil: Received Certificate: " + certificate_list.count().toStr() + " certificates"
        ' ServerKeyExchange
        else if handshake_type = self._HANDSHAKE_TYPE.SERVER_KEY_EXCHANGE
            'printl("DEBUG", "TlsUtil: Received ServerKeyExchange: " + handshake.toHexString())
            ? "TlsUtil: Received ServerKeyExchange: " + handshake.toHexString()
            self._error_handshake(self)
            return false
        ' Certificate Request
        else if handshake_type = self._HANDSHAKE_TYPE.CERTIFICATE_REQUEST
            'printl("DEBUG", "TlsUtil: Received CertificateRequest: " + handshake.toHexString())
            ? "TlsUtil: Received CertificateRequest: " + handshake.toHexString()
            self._error_handshake(self)
            return false
        ' ServerHelloDone
        else if handshake_type = self._HANDSHAKE_TYPE.SERVER_HELLO_DONE
            self._handshake_start_time = -1
            ' Verify certificate
            if not self._verify_certificate(self)
                self._error(self, self._ALERT_TYPE.BAD_CERTIFICATE, "Server certificate failed to verify", true)
                return false
            end if
            'printl("DEBUG", "TlsUtil: Received ServerHelloDone")
            ? "TlsUtil: Received ServerHelloDone"
            self._send_client_key_exchange(self)
            self._send_client_finish(self)
        ' Finished
        else if handshake_type = self._HANDSHAKE_TYPE.FINISHED
            'printl("DEBUG", "TlsUtil: Received Finished: " + handshake.toHexString())
            ? "TlsUtil: Received Finished: " + handshake.toHexString()
        end if
        return true
    end function
    
    ' Send the client finish message
    ' @param self TlsUtil
    tls_util._send_client_finish = function (self as object) as void
        
    end function
    
    ' Send the client key exchange handshake message
    ' @param self TlsUtil
    tls_util._send_client_key_exchange = function (self as object) as void
        'printl("EXTRA", "TlsUtil: Generating client key exchange message")
        ? "TlsUtil: Generating client key exchange message"
        ' TLS_RSA_WITH_AES_128_GCM_SHA256 || TLS_RSA_WITH_AES_256_GCM_SHA384 || TLS_RSA_WITH_AES_128_CBC_SHA256 || TLS_RSA_WITH_AES_256_CBC_SHA256
        if byte_array_equals(byte_array([&h00, &h9c]), self._cipher_suite) or byte_array_equals(byte_array([&h00, &h9d]), self._cipher_suite) or byte_array_equals(byte_array([&h00, &h3c]), self._cipher_suite) or byte_array_equals(byte_array([&h00, &h3d]), self._cipher_suite)
            'printl("DEBUG", "TlsUtil: Generating RSA premaster secret")
            ? "TlsUtil: Generating RSA premaster secret"
            secret = createObject("roByteArray")
            secret.append(byte_array(self._TLS_VERSION))
            for byte_index = 0 to 45
                secret.push(rnd(256) - 1)
            end for
            encrypted_secret = rsa_encrypt(secret, self._server_public_key)
        else
            'printl("FATAL", "TlsUtil: Unhandled cipher suite: " + self._cipher_suite.toStr())
            ? "TlsUtil: Unhandled cipher suite: " + self._cipher_suite.toStr()
        end if
    end function
    
    ' Verify a certificate
    ' @param self TlsUtil
    tls_util._verify_certificate = function (self as object) as boolean
        ' TODO validate the certificate
        self._server_public_key = createObject("roByteArray")
        
        certificate = self._certificates[0]
        print certificate.toHexString()

        current_byte = 0

        ' Certificate
        if certificate[current_byte] = &h30
            current_byte++
            length = 0
            length_form = bit_at_position(certificate[current_byte], 8)
            if length_form = false ' short form
                length = certificate[current_byte] and &h7F
            else if length_form = true ' long form
                additional_length_bytes = certificate[current_byte] and &h7F
                current_byte++
                length = certificate[current_byte]
                ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                for b = 1 to additional_length_bytes - 1
                    current_byte++
                    length <<= 8
                    length = length or certificate[current_byte]
                    ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                end for
            end if
            current_byte++
            ' TBSCertificate
            if certificate[current_byte] = &h30
                current_byte++
                length = 0
                length_form = bit_at_position(certificate[current_byte], 8)
                if length_form = false ' short form
                    length = certificate[current_byte] and &h7F
                else if length_form = true ' long form
                    additional_length_bytes = certificate[current_byte] and &h7F
                    current_byte++
                    length = certificate[current_byte]
                    ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                    for b = 1 to additional_length_bytes - 1
                        current_byte++
                        length <<= 8
                        length = length or certificate[current_byte]
                        ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                    end for
                end if
                current_byte++
                ' version
                if certificate[current_byte] = &hA0
                    current_byte++
                    length = 0
                    length_form = bit_at_position(certificate[current_byte], 8)
                    if length_form = false ' short form
                        length = certificate[current_byte] and &h7F
                    else if length_form = true ' long form
                        additional_length_bytes = certificate[current_byte] and &h7F
                        current_byte++
                        length = certificate[current_byte]
                        ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        for b = 1 to additional_length_bytes - 1
                            current_byte++
                            length <<= 8
                            length = length or certificate[current_byte]
                            ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        end for
                    end if
                    current_byte++
                    ' version INTEGER
                    for b = 1 to length
                        ? "version INTEGER " certificate[current_byte]
                        current_byte++
                    end for
                    ' serialNumber
                    current_byte++
                    length = 0
                    length_form = bit_at_position(certificate[current_byte], 8)
                    if length_form = false ' short form
                        length = certificate[current_byte] and &h7F
                    else if length_form = true ' long form
                        additional_length_bytes = certificate[current_byte] and &h7F
                        current_byte++
                        length = certificate[current_byte]
                        ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        for b = 1 to additional_length_bytes - 1
                            current_byte++
                            length <<= 8
                            length = length or certificate[current_byte]
                            ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        end for
                    end if
                    current_byte++
                    for b = 1 to length
                        ? "version INTEGER " certificate[current_byte]
                        current_byte++
                    end for
                    ' signature
                    current_byte++
                    length = 0
                    length_form = bit_at_position(certificate[current_byte], 8)
                    if length_form = false ' short form
                        length = certificate[current_byte] and &h7F
                    else if length_form = true ' long form
                        additional_length_bytes = certificate[current_byte] and &h7F
                        current_byte++
                        length = certificate[current_byte]
                        ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        for b = 1 to additional_length_bytes - 1
                            current_byte++
                            length <<= 8
                            length = length or certificate[current_byte]
                            ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        end for
                    end if
                    current_byte++
                    for b = 1 to length
                        ? "version INTEGER " certificate[current_byte]
                        current_byte++
                    end for
                    ' issuer
                    current_byte++
                    length = 0
                    length_form = bit_at_position(certificate[current_byte], 8)
                    if length_form = false ' short form
                        length = certificate[current_byte] and &h7F
                    else if length_form = true ' long form
                        additional_length_bytes = certificate[current_byte] and &h7F
                        current_byte++
                        length = certificate[current_byte]
                        ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        for b = 1 to additional_length_bytes - 1
                            current_byte++
                            length <<= 8
                            length = length or certificate[current_byte]
                            ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        end for
                    end if
                    current_byte++
                    for b = 1 to length
                        ? "version INTEGER " certificate[current_byte]
                        current_byte++
                    end for
                    ' validity
                    current_byte++
                    length = 0
                    length_form = bit_at_position(certificate[current_byte], 8)
                    if length_form = false ' short form
                        length = certificate[current_byte] and &h7F
                    else if length_form = true ' long form
                        additional_length_bytes = certificate[current_byte] and &h7F
                        current_byte++
                        length = certificate[current_byte]
                        ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        for b = 1 to additional_length_bytes - 1
                            current_byte++
                            length <<= 8
                            length = length or certificate[current_byte]
                            ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        end for
                    end if
                    current_byte++
                    for b = 1 to length
                        ? "version INTEGER " certificate[current_byte]
                        current_byte++
                    end for
                    ' subject
                    current_byte++
                    length = 0
                    length_form = bit_at_position(certificate[current_byte], 8)
                    if length_form = false ' short form
                        length = certificate[current_byte] and &h7F
                    else if length_form = true ' long form
                        additional_length_bytes = certificate[current_byte] and &h7F
                        current_byte++
                        length = certificate[current_byte]
                        ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        for b = 1 to additional_length_bytes - 1
                            current_byte++
                            length <<= 8
                            length = length or certificate[current_byte]
                            ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        end for
                    end if
                    current_byte++
                    for b = 1 to length
                        ? "version INTEGER " certificate[current_byte]
                        current_byte++
                    end for
                    ' subjectPublicKeyInfo
                    current_byte++
                    length = 0
                    length_form = bit_at_position(certificate[current_byte], 8)
                    if length_form = false ' short form
                        length = certificate[current_byte] and &h7F
                    else if length_form = true ' long form
                        additional_length_bytes = certificate[current_byte] and &h7F
                        current_byte++
                        length = certificate[current_byte]
                        ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        for b = 1 to additional_length_bytes - 1
                            current_byte++
                            length <<= 8
                            length = length or certificate[current_byte]
                            ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        end for
                    end if
                    current_byte++
                    ' algorithm
                    current_byte++
                    length = 0
                    length_form = bit_at_position(certificate[current_byte], 8)
                    if length_form = false ' short form
                        length = certificate[current_byte] and &h7F
                    else if length_form = true ' long form
                        additional_length_bytes = certificate[current_byte] and &h7F
                        current_byte++
                        length = certificate[current_byte]
                        ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        for b = 1 to additional_length_bytes - 1
                            current_byte++
                            length <<= 8
                            length = length or certificate[current_byte]
                            ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        end for
                    end if
                    current_byte++
                    for b = 1 to length
                        ? "version algorithm " certificate[current_byte]
                        current_byte++
                    end for
                    current_byte++
                    ' subjectPublicKey
                    length = 0
                    length_form = bit_at_position(certificate[current_byte], 8)
                    if length_form = false ' short form
                        length = certificate[current_byte] and &h7F
                    else if length_form = true ' long form
                        additional_length_bytes = certificate[current_byte] and &h7F
                        current_byte++
                        length = certificate[current_byte]
                        ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        for b = 1 to additional_length_bytes - 1
                            current_byte++
                            length <<= 8
                            length = length or certificate[current_byte]
                            ? "TlsUtil: length " length " (" current_byte ")" " (" additional_length_bytes ")"
                        end for
                    end if
                    current_byte++
                    current_byte++
                    public_key = createObject("roByteArray")
                    for b = 1 to length - 1
                        public_key.push(certificate[current_byte])
                        current_byte++
                    end for
                    ? "SERVER PUBLIC KEY " public_key.ToBase64String()
                    self._server_public_key = public_key
                end if
            end if
        end if
       
        print "--"

        return true
    end function
    
    ' Set the ready state to disconnected and send a fatal alert
    ' @param self TlsUtil
    tls_util._error_handshake = function (self as object) as void
        self._error(self, self._ALERT_TYPE.HANDSHAKE_FAILURE, "Received invalid handshake data", true)
    end function
    
    ' Set the internal socket used for sending
    ' @param self TlsUtil object
    ' @param socket roStreamSocket async TCP socket
    tls_util.set_socket = function (self as object, socket as object) as void
        self._socket = socket
    end function
    
    ' Start the TLS handshake with a ClientHello
    ' Should only be called if the client socket is a new connection
    ' @param hostname string hostname
    ' @param self TlsUtil object
    tls_util.connect = function (self as object, hostname as string) as void
        self._hostname = hostname
        self._cipher_suite = invalid
        self._handshake_buffer.clear()
        self._supported_extensions.clear()
        self._handshake_start_time = uptime(0)
        self._certificates.clear()
        self.ready_state = self.STATE_CONNECTING
        handshake = createObject("roByteArray")
        ' Body - ClientHello
        client_hello = createObject("roByteArray")
        ' Protocol version
        client_hello.append(byte_array([3, 3])) ' TLS 1.2
        ' Random
        self._client_hello_random = self._Random()
        client_hello.append(self._client_hello_random)
        ' Session id
        client_hello.push(0) ' Length
        ' Ciphersuites
        ' https://wiki.mozilla.org/Security/Server_Side_TLS#Intermediate_compatibility_.28default.29
        ciphersuites = createObject("roByteArray")
        ' TODO implement ecdhe ecdsa and chacha20
        'ciphersuites.append(byte_array([&hc0, &h2c])) ' TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
        'ciphersuites.append(byte_array([&hc0, &h30])) ' TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        'ciphersuites.append(byte_array([&hcc, &h14])) ' TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
        'ciphersuites.append(byte_array([&hcc, &h13])) ' TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256
        'ciphersuites.append(byte_array([&hc0, &h2b])) ' TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
        'ciphersuites.append(byte_array([&hc0, &h2f])) ' TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
        'ciphersuites.append(byte_array([&hc0, &h24])) ' TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384
        'ciphersuites.append(byte_array([&hc0, &h28])) ' TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384
        'ciphersuites.append(byte_array([&hc0, &h23])) ' TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256
        'ciphersuites.append(byte_array([&hc0, &h27])) ' TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256
        'ciphersuites.append(byte_array([&hc0, &h28])) ' TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384
        'ciphersuites.append(byte_array([&hc0, &h24])) ' TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384
        'ciphersuites.append(byte_array([&h00, &h67])) ' TLS_DHE_RSA_WITH_AES_128_CBC_SHA256
        'ciphersuites.append(byte_array([&h00, &h6b])) ' TLS_DHE_RSA_WITH_AES_256_CBC_SHA256
        ciphersuites.append(byte_array([&h00, &h9c])) ' TLS_RSA_WITH_AES_128_GCM_SHA256
        ciphersuites.append(byte_array([&h00, &h9d])) ' TLS_RSA_WITH_AES_256_GCM_SHA384
        ciphersuites.append(byte_array([&h00, &h3c])) ' TLS_RSA_WITH_AES_128_CBC_SHA256
        ciphersuites.append(byte_array([&h00, &h3d])) ' TLS_RSA_WITH_AES_256_CBC_SHA256
        client_hello.append(short_to_bytes(ciphersuites.count()))
        client_hello.append(ciphersuites)
        ' Compression method
        compression_methods = createObject("roByteArray")
        compression_methods.push(self._COMPRESSION_METHODS.NULL) ' Null
        client_hello.push(compression_methods.count())
        client_hello.append(compression_methods)
        ' Extensions
        extensions = createObject("roByteArray")
        extensions.append(self._generate_sni_extension(self, hostname))
        extensions.append(self._generate_supported_groups_extension(self))
        extensions.append(self._generate_ec_point_formats_extension(self))
        client_hello.append(short_to_bytes(extensions.count()))
        client_hello.append(extensions)
        ' Type
        handshake.push(self._HANDSHAKE_TYPE.CLIENT_HELLO)
        ' Length
        handshake.append(int24_to_bytes(client_hello.count()))
        ' Body
        handshake.append(client_hello)
        sent = self._send_handshake(self, handshake)
    end function
    
    ' Generate a ec point formats extension
    ' @param self TlsUtil
    ' @return roByteArray
    tls_util._generate_ec_point_formats_extension = function (self as object) as object
        extension = createObject("roByteArray")
        ' Type
        extension.append(short_to_bytes(self._EXTENSION_TYPE.EC_POINT_FORMATS))
        self._supported_extensions.push(self._EXTENSION_TYPE.EC_POINT_FORMATS)
        ' ec point formats
        ec_point_formats = createObject("roByteArray")
        formats = createObject("roByteArray")
        formats.push(self._EC_POINT_FORMATS.UNCOMPRESSED)
        ec_point_formats.push(formats.count())
        ec_point_formats.append(formats)
        extension.append(short_to_bytes(ec_point_formats.count()))
        extension.append(ec_point_formats)
        return extension
    end function
    
    ' Generate a supported groups extension
    ' @param self TlsUtil
    ' @return roByteArray
    tls_util._generate_supported_groups_extension = function (self as object) as object
        extension = createObject("roByteArray")
        ' Type
        extension.append(short_to_bytes(self._EXTENSION_TYPE.SUPPORTED_GROUPS))
        self._supported_extensions.push(self._EXTENSION_TYPE.SUPPORTED_GROUPS)
        ' Supported groups
        supported_groups = createObject("roByteArray")
        groups = createObject("roByteArray")
        for each supported_group in self._SUPPORTED_GROUPS
            groups.append(short_to_bytes(self._SUPPORTED_GROUPS[supported_group]))
        end for
        supported_groups.append(short_to_bytes(groups.count()))
        supported_groups.append(groups)
        extension.append(short_to_bytes(supported_groups.count()))
        extension.append(supported_groups)
        return extension
    end function
    
    ' Send handshake data
    ' Appends payload to handshake buffer
    ' @param self TlsUtil
    ' @param payload roByteArray handshake data
    tls_util._send_handshake = function (self as object, payload as object) as integer
        self._handshake_buffer.append(payload)
        return self._send_record(self, self._RECORD_TYPE.HANDSHAKE, payload)
    end function
    
    ' Generate a Server Name Indication (SNI) extension based on a hostname
    ' @param self TlsUtil
    ' @param hostname string hostname
    ' @return roByteArray
    tls_util._generate_sni_extension = function (self as object, hostname as string) as object
        extension = createObject("roByteArray")
        ' Type
        extension.append(short_to_bytes(self._EXTENSION_TYPE.SERVER_NAME))
        self._supported_extensions.push(self._EXTENSION_TYPE.SERVER_NAME)
        ' Server Name Indication
        sni = createObject("roByteArray")
        name_list = createObject("roByteArray")
        name_list.push(0) ' Type
        hostname_ba = createObject("roByteArray")
        hostname_ba.fromAsciiString(hostname)
        name_list.append(short_to_bytes(hostname_ba.count()))
        name_list.append(hostname_ba)
        sni.append(short_to_bytes(name_list.count()))
        sni.append(name_list)
        extension.append(short_to_bytes(sni.count()))
        extension.append(sni)
        return extension
    end function
    
    ' Returns a roByteArray that conforms to the Random struct used RFC 5246
    tls_util._Random = function () as object
        random = createObject("roByteArray")
        time = createObject("roDateTime")
        random.append(int_to_bytes(time.asSeconds()))
        for byte = 0 to 27
            random.push(rnd(256) - 1)
        end for
        return random
    end function
    
    ' Send data as a TLSPlaintext record
    ' @param self TlsUtil
    ' @param content_type integer TLS Plaintext record type
    ' @param payload roByteArray bytes to send
    tls_util._send_record = function (self as object, content_type as integer, payload as object) as integer
        if self._socket = invalid or not self._socket.isWritable()
            printl("DEBUG", "TlsUtil: Send failed: socket is not connected")
            return -1
        end if
        records = payload.count() \ self._TLS_FRAGMENT_MAX_LENGTH
        if payload.count() mod self._TLS_FRAGMENT_MAX_LENGTH <> 0
            records++
        end if
        sent_bytes = 0
        for record_index = 0 to records - 1
            ' Fragment
            fragment_index = record_index * self._TLS_FRAGMENT_MAX_LENGTH
            max = fragment_index + self._TLS_FRAGMENT_MAX_LENGTH - 1
            if payload.count() - 1 < max
                max = payload.count() - 1
            end if
            fragment = createObject("roByteArray")
            for byte_index = fragment_index to max
                fragment[byte_index] = payload[byte_index]
            end for
            ' Record
            record = createObject("roByteArray")
            record.push(content_type)
            ' TLS version
            record.append(byte_array(self._TLS_VERSION))
            ' Length
            record.append(short_to_bytes(fragment.count()))
            ' Payload fragment
            record.append(fragment)
            'printl("VERBOSE", "TlsUtil: Sending: " + record.toHexString())
            ? "TlsUtil: Sending: " record.toHexString()
            ' Send
            sent = self._socket.send(record, 0, record.count())
            if sent = record.count()
                sent_bytes += fragment.count()
            end if
        end for
        return sent_bytes
    end function
    
    ' Send data through the TLS tunnel over the socket
    ' @param self TlsUtil object
    ' @param payload roByteArray data to send
    ' @return bytes of payload sent
    tls_util.send = function (self as object, payload as object) as integer
        ' TODO encrypt data
        return self._send_record(self, self._RECORD_TYPE.APPLICATION_DATA, payload)
    end function
    
    ' Send string through the TLS tunnel over the socket
    ' @param self TlsUtil object
    ' @return bytes of payload sent
    tls_util.send_str = function (self as object, payload as string) as integer
        ba = createObject("roByteArray")
        ba.fromAsciiString(payload)
        return self.send(self, ba)
    end function
    
    ' Set internal buffer size
    ' @param self TlsUtil
    ' @param size integer
    tls_util.set_buffer_size = function (self as object, size as integer) as void
        if self.ready_state <> self.STATE_DISCONNECTED
            printl("WARN", "TlsUtil: Cannot set buffer size while connection is open")
            return
        end if
        self._BUFFER_SIZE = size
    end function
    
    return tls_util
end function