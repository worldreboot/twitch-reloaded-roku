' ByteUtil.brs
' Copyright (C) 2018 Rolando Islas
' Released under the MIT license
'
' Byte array operation related utilities

' Convert network ordered bytes to a short (16-bit int)
function bytes_to_short(b1 as integer, b2 as integer) as integer
    return ((b1 and &hff) << 8) or (b2 and &hff)
end function

' Convert network ordered bytes to a long (64-bit int)
function bytes_to_long(b1 as integer, b2 as integer, b3 as integer, b4 as integer, b5 as integer, b6 as integer, b7 as integer, b8 as integer) as longinteger
    return ((b1 and &hff) << 24) or ((b2 and &hff) << 16) or ((b3 and &hff) << 8) or (b4 and &hff) or ((b5 and &hff) << 24) or ((b6 and &hff) << 16) or ((b7 and &hff) << 8) or (b8 and &hff)
end function

' Convert network ordered bytes to a long (64-bit int)
function byte_array_to_long(b as object) as longinteger
    return bytes_to_long(b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7])
end function

' Convert network ordered bytes to an int (32-bit)
function bytes_to_int(b1 as integer, b2 as integer, b3 as integer, b4 as integer) as integer
    return (b1 << 24) or ((b2 and &hff) << 16) or ((b3 and &hff) << 8) or (b4 and &hff)
end function

' Convert network ordered byres to an int (24-bit)
function bytes_to_int24(b1 as integer, b2 as integer, b3 as integer) as integer
    return ((b1 and &hff) << 16) or ((b2 and &hff) << 8) or (b3 and &hff)
end function

' Convert a 32-bit int to a roByteArray
' Bytes are network ordered
function int_to_bytes(number as integer) as object
    ba = createObject("roByteArray")
    if ba.isLittleEndianCPU()
        for bit = 24 to 0 step -8
            ba.push((number >> bit) and &hff)
        end for
    else
        for bit = 0 to 24 step 8
            ba.push((number >> bit) and &hff)
        end for
    end if
    return ba
end function

' Convert a 16-bit int to a roByteArray
' Bytes are network ordered
function short_to_bytes(number as integer) as object
    ba = createObject("roByteArray")
    if ba.isLittleEndianCPU()
        ba.push((number >> 8) and &hff)
        ba.push(number)
    else
        ba.push(number)
        ba.push((number >> 8) and &hff)
    end if
    return ba
end function

' Convert a 64-bit int to a roByteArray
' Bytes are network ordered
' FIXME bitwise operations on numbers larger than 0xffffffff (max 32-bit)
'       are problematic even when specifying longinteger
function long_to_bytes(number as longinteger) as object
    ba = createObject("roByteArray")
    if ba.isLittleEndianCPU()
        for bit = 7 to 0 step -1
            ba[bit] = (number and &hff)
            number >>= 8
        end for
    else
        for bit = 0 to 56 step 8
            ba.push((number >> bit) and &hff)
        end for
    end if
    return ba
end function

' Convert a 24-bit int to a roByteArray
' Bytes are network ordered
function int24_to_bytes(number as integer) as object
    ba = createObject("roByteArray")
    if ba.isLittleEndianCPU()
        for bit = 16 to 0 step -8
            ba.push((number >> bit) and &hff)
        end for
    else
        for bit = 0 to 16 step 8
            ba.push((number >> bit) and &hff)
        end for
    end if
    return ba
end function

' Convert a roArray to a roByteArray
function byte_array(array as object) as object
    ba = createObject("roByteArray")
    for each byte in array
        ba.push(byte)
    end for
    return ba
end function

' Return a sub roByteArray of a passed roByteArray
' @param ba roByteArray array to use for sub array operations
' @param start_index integer index to start sub array (inclusive)
' @param end_index integer index to end sub array (inclusive)
function byte_array_sub(ba as object, start_index as integer, end_index = -1 as integer) as object
    if end_index = -1
        end_index = ba.count() - 1
    end if
    ba_sub = createObject("roByteArray")
    for byte_index = start_index to end_index
        ba_sub.push(ba[byte_index])
    end for
    return ba_sub
end function

' Check that two byte arrays are equal
' @param a roByteArray first array
' @param b roByteArray seconds array
' @return byte arrays equivalence
function byte_array_equals(a as object, b as object) as boolean
    if a.count() <> b.count()
        return false
    end if
    for byte_index = 0 to a.count() - 1
        if a[byte_index] <> b[byte_index]
            return false
        end if
    end for
    return true
end function

' Encrtpt a byte array with an RSA public key
function rsa_encrypt(public_key as object, ba as object) as object
    encrypted_ba = createObject("roByteArray")
    return encrypted_ba
end function

' Perform a bitwise exclusive or on two integers
function xor(a as integer, b as integer) as integer
    return (a or b) and not (a and b)
end function