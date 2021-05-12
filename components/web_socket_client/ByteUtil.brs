' ByteUtil.brs
' Copyright (C) 2018 Rolando Islas
' Released under the MIT license
'
' Byte array operation related utilities

' len8tab = [ &h00, &h01, &h02, &h02, &h03, &h03, &h03, &h03, &h04, &h04, &h04, &h04, &h04, &h04, &h04, &h04,
'             &h05, &h05, &h05, &h05, &h05, &h05, &h05, &h05, &h05, &h05, &h05, &h05, &h05, &h05, &h05, &h05,
'             &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06,
'             &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06, &h06,
'             &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07,
'             &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07,
'             &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07,
'             &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07, &h07,
'             &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08,
'             &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08,
'             &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08,
'             &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08,
'             &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08,
'             &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08,
'             &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08,
'             &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08, &h08 ]

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

' Encrypt a byte array with an RSA public key
function rsa_encrypt(ba as object, public_key as object) as object
    encrypted_ba = createObject("roByteArray")
    public_key_pair = rsa_get_modulus_and_exponent(public_key)
    n = public_key_pair[0]
    e = public_key_pair[1]
    ' cur = ba
    ' ? "mod test: " mod_bytes([&h57, &h92], [&h99])
    ' exps = createObject("roArray", 0, true)
    ' idx = 0
    ' exps.push(ba)
    ' for i = e.count() - 1 to 0 step -1
    '     ? "i = " i
    '     for j = 1 to 8
    '         ? " j = " j
    '         exps.push(multiply_bytes(exps[idx], ba))
    '         idx++
    '         if bit_at_position(e[i], j)
    '             cur = multiply_bytes(cur, exps[idx])
    '             if is_greater(cur, n)
    '                 ? "cur: " cur.count()
    '                 cur = mod_bytes(cur, n)
    '             end if
    '         end if
    '     end for
    ' end for
    ' ? "exps: " exps
    ' ? "cur: " cur.toBase64String()

    ? "Add test: " Add(9223372036854775807, 1844674407999999, 0)

    return encrypted_ba
end function

' Perform a bitwise exclusive or on two integers
function xor(a as integer, b as integer) as integer
    return (a or b) and not (a and b)
end function

function bit_at_position(a as integer, position as integer) as boolean
    position_num = 1
    position_num <<= position - 1
    if (a and position_num) > 0
        return true
    else 
        return false
    end if
end function

function greater_than_zero(ba as object) as boolean
    for i = 0 to ba.count() - 1
        if ba[i] <> 0
            return true
        end if
    end for
    return false
end function

' return a mod b
function mod_bytes(a as object, b as object) as object
    remainder = createObject("roByteArray")
    cur = 0
    if is_greater(b, a)
        return a
    else
        div = createObject("roByteArray")
        while cur < a.count()
            while is_greater(b, div) and cur < a.count()
                div.push(a[cur])
                cur++
            end while
            cnt = 0
            while is_greater(div, b)
                cnt++
                div = subtract_bytes(div, b)
            end while
            ? "mod cur: " cur
        end while
        remainder = div
    end if
    return remainder
end function

' subtract byte array b from byte array a and return difference
function subtract_bytes(a as object, b as object) as object
    difference = createObject("roByteArray")
    length_diff = a.count() - b.count()
    for i = b.count() - 1 to 0 step -1
        if a[i + length_diff] < b[i]
            if i + length_diff > 0 and a[i + length_diff - 1] - 1 < 0
                a[i + length_diff - 1] = &hFF
            else if i + length_diff > 0 and a[i + length_diff - 1] - 1 >= 0
                a[i + length_diff - 1] -= 1
            end if
            difference.push((256 or a[i + length_diff]) - b[i])
        else
            difference.push(a[i + length_diff] - b[i])
        end if
    end for
    sig = 0
    while a[sig] = 0 and sig <= length_diff - 1
        sig++
    end while
    for i = length_diff - 1 to sig step -1
        difference.push(a[i])
    end for
    '? "difference: " difference
    difference = reverse(difference)
    return difference
end function

' return the reverse of the input byte array
function reverse(ba as object) as object
    reversed = createObject("roByteArray")
    for i = ba.count() - 1 to 0 step -1
        reversed.push(ba[i])
    end for
    return reversed
end function

' is byte array a greater than byte array b
function is_greater(a as object, b as object) as boolean
    if a.count() > b.count()
        return true
    else if a.count() < b.count()
        return false
    else
        for i = 0 to a.count() - 1
            if a[i] > b[i]
                return true
            else if a[i] < b[i]
                return false
            end if
        end for
    end if
    return false
end function

function multiply_bytes(a as object, b as object) as object
    final_product = createObject("roByteArray")
    '? "multiply_bytes >> a >" a
    '? "multiply_bytes >> b > " b
    last_sum = invalid
    next_sum = createObject("roByteArray")
    for i = b.count() - 1 to 0 step -1
        '? "multiply_bytes >> last_sum > " last_sum
        carry = 0
        for j = 0 to b.count() - i - 2
            next_sum.push(0)
        end for
        for j = a.count() - 1 to 0 step -1
            product = a[j] * b[i] + carry
            '? "multiply_bytes >> product > " product
            low_byte = product and &hFF
            '? "multiply_bytes >> low_byte > " low_byte
            carry = product >> 8
            '? "multiply_bytes >> carry > " carry
            next_sum.push(low_byte)
        end for
        if carry > 0
            next_sum.push(carry)
        end if
       ' ? "multiply_bytes >> next_sum > " next_sum
        if last_sum = invalid
            last_sum = createObject("roByteArray")
            last_sum = next_sum
            next_sum = createObject("roByteArray")
        else
            carry = 0
            if last_sum.count() > next_sum.count()
                for j = 0 to next_sum.count() - 1
                    sum = next_sum[j] + last_sum[j] + carry
                    low_byte = sum and &hFF
                    carry = sum >> 8
                    last_sum[j] = low_byte
                end for
                for j = next_sum.count() to last_sum.count() - 1
                    sum = last_sum[j] + carry
                    low_byte = sum and &hFF
                    carry = sum >> 8
                    last_sum[j] = low_byte
                end for
            else
                for j = 0 to last_sum.count() - 1
                    sum = next_sum[j] + last_sum[j] + carry
                    low_byte = sum and &hFF
                    carry = sum >> 8
                    last_sum[j] = low_byte
                end for
                for j = last_sum.count() to next_sum.count() - 1
                    sum = next_sum[j] + carry
                    low_byte = sum and &hFF
                    carry = sum >> 8
                    last_sum.push(low_byte)
                end for
            end if
            if carry > 0
                last_sum.push(carry)
            end if
        end if
        next_sum.clear()
    end for
    ' for i = last_sum.count() - 1 to 0 step -1
    '     final_product.push(last_sum[i])
    ' end for
    final_product = reverse(last_sum)
    return final_product
end function

' Get n (modulus) from an RSA public key
function rsa_get_modulus_and_exponent(public_key as object) as object
    public_key_pair = createObject("roArray", 2, false)
    modulus = createObject("roByteArray")
    exponent = createObject("roByteArray")

    current_byte = 0

    if public_key[current_byte] = &h30
        current_byte++
        length = 0
        length_form = bit_at_position(public_key[current_byte], 8)
        if length_form = false ' short form
            length = public_key[current_byte] and &h7F
        else if length_form = true ' long form
            additional_length_bytes = public_key[current_byte] and &h7F
            current_byte++
            length = public_key[current_byte]
            for b = 1 to additional_length_bytes - 1
                current_byte++
                length <<= 8
                length = length or public_key[current_byte]
            end for
        end if
        current_byte++
        ' modulus INTEGER
        if public_key[current_byte] = &h02
            current_byte++
            length = 0
            length_form = bit_at_position(public_key[current_byte], 8)
            if length_form = false ' short form
                length = public_key[current_byte] and &h7F
            else if length_form = true ' long form
                additional_length_bytes = public_key[current_byte] and &h7F
                current_byte++
                length = public_key[current_byte]
                for b = 1 to additional_length_bytes - 1
                    current_byte++
                    length <<= 8
                    length = length or public_key[current_byte]
                end for
            end if
            current_byte++
            for b = 1 to length
                ? "modulus INTEGER " public_key[current_byte]
                modulus.push(public_key[current_byte])
                current_byte++
            end for
            public_key_pair[0] = modulus
            ' exponent INTEGER
            if public_key[current_byte] = &h02
                current_byte++
                length = 0
                length_form = bit_at_position(public_key[current_byte], 8)
                if length_form = false ' short form
                    length = public_key[current_byte] and &h7F
                else if length_form = true ' long form
                    additional_length_bytes = public_key[current_byte] and &h7F
                    current_byte++
                    length = public_key[current_byte]
                    for b = 1 to additional_length_bytes - 1
                        current_byte++
                        length <<= 8
                        length = length or public_key[current_byte]
                    end for
                end if
                current_byte++
                for b = 1 to length
                    ? "exponent INTEGER " public_key[current_byte]
                    exponent.push(public_key[current_byte])
                    current_byte++
                end for
                public_key_pair[1] = exponent
            end if
        end if
    end if

    return public_key_pair
end function

' Modular exponentiation z = x^y mod mm
function ModExp(x as object, y as object, mm as object) as object
    z = expNN(x, y, mm)
    return z
end function

function expNN(x as object, y as object, mm as object) as object
    z = createObject("roByteArray")

    ' x^y mod 1 == 0
    if mm.count() = 1 and mm[0] = 1
        z.push(0)
        return z
    end if

    ' x^0 == 1
    if y.count() = 0
        z.push(1)
        return z
    end if

    ' x^1 mod mm == x mod mm
    if y.count() = 1 and y[0] = 1 and mm.count() <> 0
        q_r = div(z, x, mm)
        z = q_r.r
        return z
    end if

    ' y > 1

    if mm.count() <> 0
        z = getBig(mm.count())
    end if
    z = set(z, x)

    if cmp(x, natOne) > 0 and y.count() > 1 and mm.count() > 0
        if (mm[0] and 1) = 1
            return expNNMontgomery(z, x, y, mm)
        end if
        return expNNWindowed(z, x, y, mm)
    end if

end function

function expNNWindowed(z as object, x as object, y as object, mm as object) as object
    n = 4
    powers = createObject("roArray", 1 << n, false)
    one = createObject("roByteArray")
    one.push(1)
    powers[0] = one
    powers[1] = x
    i = 2
    while i < (1 << n)
        p2 = powers[i / 2]
        p = powers[i]
        p1 = powers[i + 1]
        
        i += 2
    end while
end function

function expNNMontgomery(z as object, x as object, y as object, mm as object) as object
    numWords = mm.count()

    if x.count() > numWords
        nil = createObject("roByteArray")
        q_r = div(nil, x, mm)
        x = q_r.r
    end if
    if x.count() < numWords
        rr = getBig(numWords)
        copy(rr, x)
        x = rr
    end if

    k0 = 2 - mm[0]
    t = mm[0] - 1
    i = 1
    while i < 64
        t = t * t
        k0 = k0 * (t + 1)
        i <<= 1
    end while
    k0 = -k0

    rr2 = createObject("roByteArray")
    rr2.push(1)
    nil = createObject("roByteArray")
    zz = shl(nil, rr2, 2 * numWords * 64)
    nil = createObject("roByteArray")
    q_r = div(rr2, zz, mm)
    rr2 = q_r.r
    if rr2.count() < numWords
        zz = getBig(numWords)
        copy(zz, rr2)
        rr2 = zz
    end if

    one = getBig(numWords)
    one[0] = 1

    n = 4
    powers = createObject("roArray", 1 << n, false)
    powers[0] = montgomery(powers[0], one, rr2, mm, k0, numWords)
    powers[1] = montgomery(powers[1], x, rr2, mm, k0, numWords)
    i = 2
    while i < (1 << n)
        powers[i] = montgomery(powers[i], powers[i - 1], powers[1], mm, k0, numWords)
    end while

    z = getBig(numWords)
    copy(z, powers[0])

    zz = getBig(numWords)

    i = y.count() - 1
    while i >= 0
        yi = y[i]
        j = 0
        while j < 64
            if i <> y.count() - 1 or j <> 0
                zz = montgomery(zz, z, z, mm, k0, numWords)
                z = montgomery(z, zz, zz, mm, k0, numWords)
                zz = montgomery(zz, z, z, mm, k0, numWords)
                z = montgomery(z, zz, zz, mm, k0, numWords)
            end if
            zz = montgomery(zz, z, powers[yi >> (64 - n)], mm, k0, numWords)
            tmp = zz
            set(z, zz)
            set(zz, tmp)
            yi <<= n
            j += n
        end while
        i--
    end while

    zz = montgomery(zz, z, one, mm, k0, numWords)

    if cmp(zz, mm) >= 0
        zz = sub_big(zz, zz, mm)
        if cmp(zz, mm) >= 0
            nil = createObject("roByteArray")
            q_r = div(nil, zz, mm)
            zz = q_r.r
        end if
    end if

    return norm(zz)
end function

function sub_big(z as object, x as object, y as object) as object
    l = x.count()
    n = y.count()

    if l < n
        return invalid
    else if l = 0
        nil = createObject("roByteArray")
        return nil
    else n = 0
        return set(z, x)
    end if
    ' m > 0

    z = getBig(l)
    c = subVV_g(byte_array_sub(z, 0, n), x, y)
    if l > n
        c = subVW_g(byte_array_sub(z, n, -1), byte_array_sub(x, n, -1), c)
    end if
    if c <> 0
        return invalid
    end if

    return norm(z)
end function

function montgomery(z as object, x as object, y as object, mm as object, k, n as integer) as object
    if x.count() <> n or y.count() <> n or mm.count() <> n
        return invalid
    end if
    z = getBig(n * 2)
    clearToZero(z)
    c = 0
    i = 0
    while i < n
        d = y[i]
        c2 = addMulVVW_g(byte_array_sub(z, i, n + i), x, d)
        t = z[i] * k
        c3 = addMulVVW_g(byte_array_sub(z, i, n + i), mm, t)
        cx = c + c2
        cy = cx + c3
        z[n + i] = cy
        if cx < c2 or cy < c3
            c = 1
        else
            c = 0
        end if
        i++
    end while
    if c <> 0
        subVV_g(byte_array_sub(z, 0, n), byte_array_sub(z, n, -1), mm)
    else
        copy(byte_array_sub(z, 0, n), byte_array_sub(z, n, -1))
    end if
    return byte_array_sub(z, 0, n)
end function

function shl(z as object, x as object, s) as object
    if s = 0
        return set(z, x)
    end if

    l = x.count()
    if l = 0
        nil = createObject("roByteArray")
        return nil
    end if
    ' l > 0

    n = l + int(s / 64)
    z = getBig(n + 1)
    z[n] = shlVU(byte_array_sub(z, n - l, n), x, s MOD 64)
    clearFrom(z, 0, n - l)
    
    return norm(z)
end function

function div(z2 as object, u as object, v as object) as object
    z = createObject("roByteArray")
    if v.count() = 0
        return invalid
    end if
    
    q_r = {}

    if cmp(u, v) < 0
        q = z
        r = set(z2, u)
        q_r.q = q
        q_r.r = r
        return q_r
    end if

    if v.count() = 1
        q_r = divW(z, u, v[0])
        q = q_r.q
        r2 = q_r.r
        z2.clear()
        z2.push(r2)
        r = z2
        q_r.q = q
        q_r.r = r
        return q_r
    end if

    q_r = divLarge(z, z2, u, v)
    
    return q_r
end function

' q = (uIn-r)/vIn, with 0 <= r < vIn
function divLarge(z, u, uIn, vIn) as object
    n = vIn.count()
    l = uIn.count() - n

    sh = nlz(vIn[n - 1])

    vp = getBig(n)
    v = vp
    shlVU(v, vIn, sh)

    u = getBig(uIn.count() + 1)
    u[uIn.count()] = shlVU(byte_array_sub(u, 0, uIn.count()), uIn, sh)

    q = getBig(l + 1)

    if n < 100
        divBasic(q, u, v)
    else
        divRecursive(q, u, v)
    end if

    q = norm(q)
    shrVU_g(u, u, sh)
    r = norm(u)

    q_r = {}
    q_r.q = q
    q_r.r = r

    return q_r
end function

function shrVU_g(z as object, x as object, s)
    if s = 0
        copy(z, x)
        return invalid
    end if
    if z.count() = 0
        return invalid
    end if
    if x.count() <> z.count()
        return invalid
    end if
    s = s and (64 - 1)
    shat = 64 - s
    shat = shat and (64 - 1)
    c = x[0] << shat
    i = 1
    while i < z.count()
        z[i - 1] = (x[i - 1] >> s) or (x[i] << shat)
        i++
    end while
    z[z.count() - 1] = x[z.count() - 1] >> s
    return invalid
end function

function divRecursive(z as object, u as object, v as object)
    recDepth = 2 * Len64(v.count())
    tmp = getBig(3 * v.count())
    temps = createObject("roArray", 0, true)
    clearToZero(z)
    divRecursiveStep(z, u, v, 0, tmp, temps)
end function

function divRecursiveStep(z as object, u as object, v as object, depth as integer, tmp as object, temps as object)
    u = norm(u)
    v = norm(v)

    if u.count() = 0
        clearToZero(z)
        return invalid
    end if
    n = v.count()
    if n < 100
        divBasic(z, u, v)
        return invalid
    end if
    l = u.count() - n
    if l < 0
        return invalid
    end if
    
    B = n / 2
    if temps[depth] = invalid
        temps[depth] = getBig(n)
    end if

    j = l
    while j > B
        s = (B - 1)

        uu = byte_array_sub(u, j - B, -1)

        qhat = temps[depth]
        clearToZero(qhat)
        divRecursiveStep(qhat, byte_array_sub(uu, s, B + n), byte_array_sub(v, s, -1), depth + 1, tmp, temps)
        qhat = norm(qhat)

        qhatv = getBig(3 * n)
        qhatv = multiply(qhatv, qhat, byte_array_sub(v, 0, s))
        for i = 0 to 2
            e = cmp(qhatv, norm(uu))
            if e <= 0
                exit for
            end if
            subVW_g(qhat, qhat, 1)
            c = subVV_g(byte_array_sub(qhatv, 0, s), byte_array_sub(qhatv, 0, s), byte_array_sub(v, 0, s))
            if qhatv.count() > s
                subVW_g(byte_array_sub(qhatv, s, -1), byte_array_sub(qhatv, s, -1), c)
            end if
            addAt(byte_array_sub(uu, s, -1), byte_array_sub(v, s, -1), 0)
        end for
        if cmp(qhatv, norm(uu)) > 0
            return invalid
        end if
        c = subVV_g(byte_array_sub(uu, 0, qhatv.count()), byte_array_sub(uu, qhatv.count(), -1), qhatv)
        if c > 0
            subVW_g(byte_array_sub(uu, qhatv.count(), -1), byte_array_sub(uu, qhatv.count()), c)
        end if
        addAt(z, qhat, j - B)
    end while

    s = B - 1
    qhat = temps[depth]
    clearToZero(qhat)
    divRecursiveStep(qhat, norm(byte_array_sub(u, s, -1)), byte_array_sub(v, s, -1), depth + 1, tmp, temps)
    qhat = norm(qhat)
    qhatv = getBig(3 * n)
    clearToZero(qhatv)
    qhatv = multiply(qhatv, qhat, byte_array_sub(v, 0, s))
    i = 0
    while i < 2
        e = cmp(qhatv, norm(e))
        if e > 0
            subVW_g(qhat, qhat, 1)
            c = subVV_g(byte_array_sub(qhatv, 0, s), byte_array_sub(qhatv, 0, s), byte_array_sub(v, 0, s))
            if qhatv.count()
                subVW_g(byte_array_sub(qhatv, s, -1), byte_array_sub(qhatv, s, -1), c)
            end if
            addAt(byte_array_sub(u, s, -1), byte_array_sub(v, s, -1), 0)
        end if
        i++
    end while
    if cmp(qhatv, norm(u)) > 0
        return invalid
    end if
    c = subVV_g(byte_array_sub(u, 0, qhatv.count()), byte_array_sub(u, 0, qhatv.count()), qhatv)
    if c > 0
        c = subVW_g(byte_array_sub(u, qhatv.count(), -1), byte_array_sub(u, qhatv.count(), -1), c)
    end if
    if c > 0
        return invalid
    end if

    addAt(z, norm(qhat), 0)
end function

function subVW_g(z as object, x as object, y)
    c = y
    i = 0
    while i < z.count() and i < x.count()
        d_b = Subtract(x[i], c, 0)
        zi = d_b.diff
        cc = d_b.borrowOut
        z[i] = zi
        c = cc
        i++
    end while
    return c
end function

function multiply(z as object, x as object, y as object) as object
    l = x.count()
    n = y.count()

    if l < n
        return multiply(z, y, x)
    else if l = 0 or n = 0
        zero = createObject("roByteArray")
        return zero
    else n = 1
        return mulAddWW(z, x, y[0], 0)
    end if
    ' l >= n > 1

    if n < 40
        z = getBig(l + n)
        basicMul(z, x, y)
        return norm(z)
    end if

    k = karatsubaLen(n, 40)

    ' k <= n

    x0 = byte_array_sub(x, 0, k)
    y0 = byte_array_sub(y, 0, k)
    if (6 * k) > (l + n)
        z = getBig(6 * k)
    else
        z = getBig(l + n)
    end if
    karatsuba(z, x0, y0)
    z = byte_array_sub(z, 0, l + n)
    clearFrom(z, 2 * k)

    if k < n or l <> n
        tp = getBig(3 * k)
        t = tp

        x0 = norm(x0)
        y1 = byte_array_sub(y, k, -1)
        t = multiply(t, x0, y1)
        addAt(z, t, k)

        y0 = norm(y0)
        i = k
        while i < x.count()
            xi = byte_array_sub(x, i, -1)
            if xi.count() > k
                xi = byte_array_sub(xi, 0, k)
            end if
            xi = norm(x1)
            t = multiply(t, xi, y0)
            addAt(z, t, i)
            t = multiply(t, xi, y1)
            addAt(z, t, i + k)
            i += k
        end while
    end if

    return norm(z)
end function

function addAt(z as object, x as object, i as integer)
    n = x.count()
    if n > 0
        c = addVV_g(byte_array_sub(z, i, i + 1), byte_array_sub(z, i, -1), x)
        if c <> 0
            j = i + n
            if j < z.count()
                addVW_g(byte_array_sub(z, j, -1), byte_array_sub(z, j, -1), c)
            end if
        end if
    end if
end function

function clearFrom(z as object, position as integer)
    for i = position to z.count() - 1
        z[i] = 0
    end for
end function

function karatsuba(z as object, x as object, y as object)
    n = y.count()
    
    if (n and 1) <> 0 or n < 40 or n < 2
        basicMul(z, x, y)
        return invalid
    end if

    n2 = n >> 1
    x1 = byte_array_sub(x, n2, -1)
    x0 = byte_array_sub(x, 0, n2)

    y1 = byte_array_sub(y, n2, -1)
    y0 = byte_array_sub(y, 0, n2)

    karatsuba(z, x0, y0)
    karatsuba(byte_array_sub(z, n, -1), x1, y1)

    s = 1
    xd = byte_array_sub(z, 2 * n, 2 * n + n2)
    if subVV_g(xd, x0, x1) <> 0
        s = -s
        subVV_g(xd, x0, x1)
    end if

    yd = byte_array_sub(z, 2*n + n2, 3 * n)
    if subVV_g(yd, y0, y1) <> 0
        s = -s
        subVV_g(yd, y1, y0)
    end if

    p = byte_array_sub(z, n * 3, -1)
    karatsuba(p, xd, yd)

    r = byte_array_sub(z, n * 4, -1)
    copy(r, byte_array_sub(z, 0, n * 2))

    karatsubaAdd(byte_array_sub(z, n2, -1), r, n)
    karatsubaAdd(byte_array_sub(z, n2, -1), byte_array_sub(r, n, -1), n)
    if s > 0
        karatsubaAdd(byte_array_sub(z, n2, -1), p, n)
    else
        karatsubaAdd(byte_array_sub(z, n2, -1), p, n)
    end if
end function

function copy(dst as object, src as object) as integer
    i = 0
    while i < dst.count() and i < src.count()
        dst[i] = src[i]
        i++
    end while
    return i
end function

function karatsubaAdd(z as object, x as object, n as integer)
    c = addVV_g(byte_array_sub(z, 0, n), z, x)
    if c <> 0
        addVW_g(byte_array_sub(z, n, n + n >> 1), byte_array_sub(z, n, -1), c)
    end if
end function

function addVW_g(z as object, x as object, y)
    c = y
    i = 0
    while i < z.count() and i < x.count()
        s_c = Add(x[i], c, 0)
        zi = s_c.sum
        cc = s_c.carryOut
        z[i] = zi
        c = cc
    end while
    return c
end function

function karatsubaLen(n as integer, threshold as integer)
    i = 0
    while n > threshold
        n >>= 1
        i++
    end while
    return n << i
end function

function basicMul(z, x, y)
    z = getBig(x.count() + y.count())
    i = 0
    d = 0
    while i < y.count() and d < y.count()
        if d <> 0
            z[x.count() + i] = addMulVVW_g(byte_array_sub(z, i, i + x.count()), x, d)
        end if
        i++
        d++
    end while 
end function

function addMulVVW_g(z as object, x as object, y as integer) as integer
    i = 0
    c = 0
    while i < z.count() and i < x.count()
        z_z = mulAddWWW_g(x[i], y, z[i])
        z1 = z_z.z1
        z0 = z_z.z0
        s_c = Add(z0, c, 0)
        lo = s_c.sum
        cc = s_c.carryOut
        c = cc
        z[i] = lo
        c += z1
        i++
    end while
    return c
end function

function mulAddWWW_g(x, y, c) as object
    h_l = Mul(x, y)
    hi = h_l.hi
    lo = h_l.lo
    cc = 0
    s_c = Add(lo, c, 0)
    lo = s_c.sum
    cc = s_c.carryOut
    z_z = {}
    z_z.z1 = hi + cc
    z_z.z0 = lo
    return z_z
end function

function mulAddWW(z as object, x as object, y, r) as object
    l = x.count()
    if l = 0 or y = 0
        z.clear()
        z.push(r)
        return z
    end if
    ' l > 0

    z = getBig(l + 1)
    z[l] = mulAddVWW(byte_array_sub(z, 0, l), x, y, r)

    return norm(z)
end function

function clearToZero(z as object)
    for i = 0 to z.count() - 1
        z[i] = 0
    end for
end function

function divBasic(q as object, u as object, v as object)
    n = v.count()
    l = u.count() - n

    _B = (1 << 64)
    _M = _B - 1

    qhatvp = getBig(n + 1)
    qhatv = qhatvp

    vn1 = v[n - 1]
    rec = reciprocalWord(vn1)
    for j = l to 0 step -1
        qhat = _M
        ujn = 0
        if j + n < u.count()
            ujn = u[j + n]
        end if
        if ujn <> vn1
            rhat = 0
            q_r = divWW(ujn, u[j + n - 1], vn1, rec)
            qhat = q_r.q
            rhat = q_r.r

            vn2 = v[n - 2]
            h_l = mulWW_g(qhat, vn2)
            x1 = h_l.hi
            x2 = h_l.lo

            ujn2 = u[j + n - 2]
            while greaterThan(x1, x2, rhat, ujn2)
                qhat--
                prevRhat = rhat
                rhat += vn1

                if rhat < prevRhat
                    exit while
                end if
                h_l = mulWW_g
                x1 = h_l.hi
                x2 = h_l.lo
            end while
        end if

        qhatv[n] = mulAddVWW(byte_array_sub(qhatv, 0, n), v, qhat, 0)
        qhl = qhatv.count()
        if j + qhl > u.count() and qhatv[n] = 0
            qhl--
        end if
        c = subVV_g(byte_array_sub(u, j, j + n), byte_array_sub(u, j, -1), v)
        if c <> 0
            c = addVV_g(byte_array_sub(u, j, j + n), byte_array_sub(u, j, -1), v)
            if n < qhl
                u[j + n] += c
            end if
            qhat--
        end if

        if not (j = l and l = q.count() and qhat = 0)
            q[j] = qhat
        end if
    end for
end function

function addVV_g(z as object, x as object, y as object)
    i = 0
    c = 0
    while i < z.count() and i < x.count() and i < y.count()
        s_c = Add(x[i], y[i], c)
        zi = s_c.sum
        cc = s_c.carryOut
        z[i] = zi
        c = cc
        i++
    end while
    return c
end function

function subVV_g(z as object, x as object, y as object) 
    i = 0
    c = 0
    while i < z.count() and i < x.count() and i < y.count()
        d_c = Subtract(x[i], y[i], c)
        zi = d_c.diff
        cc = d_c.borrowOut
        z[i] = zi
        c = cc
        i++
    end while 
    return c
end function

' z1<<_W + z0 = x*y + c
function mulAddVWW(x, y, c)
    h_l = Mul(x, y)
    hi = h_l.hi
    lo = h_l.lo
    cc = 0
    s_c = Add(lo, c, 0)
    lo = s_c.sum
    cc = s_c.carryOut
    z_z = {}
    z_z.z1 = hi + cc
    z_z.z0 = lo
    return z_z
end function

function greaterThan(x1, x2, y1, y2) as boolean
    return x1 > y1 or x1 = y1 and x2 > y2
end function

' z1<<_W + z0 = x*y + c
function mulWW_g(x, y)
    return Mul(x, y)
end function

function shlVU_g(z as object, x as object, s)
    if s = 0
        set(z, x)
        return 0
    end if
    if z.count() = 0
        return 0
    end if
    s = s and (64 - 1)
    s_ = 64 - s
    s_ = s_ and (64 - 1)
    c = x[z.count() - 1] >> s_
    for i = z.count() - 1 to 1 step -1
        z[i] = x[i] << s or x[i - 1] >> s_
    end for
    z[0] = x[0] << s
    return c
end function

function shlVU(z as object, x as object, y)
    return shlVU_g(z, x, s)
end function

function getBig(n) as object
    z = createObject("roByteArray")
    for i = 1 to n
        z.push(0)
    end for
    return z
end function

function divW(z as object, x as object, y as integer) as object
    n = x.count()
    q_r = {}
    q_r.r = 0
    if y = 0
        return invalid
    else if y = 1
        q_r.q = set(z, x)
        return q_r
    else if n = 0
        q_r.q = createObject("roByteArray")
        return q_r
    end if

    ' n > 0
    q_r.r = divWVW(z, 0, x, y)
    q_r.q = norm(z)

    return q_r
end function

function norm(z as object) as object
    i = z.count()
    while i > 0 and z[i - 1] = 0
        i--
    end while
    return byte_array_sub(z, 0, i)
end function

function divWVW(z as object, xn as integer, x as object, y as integer) as integer
    r = xn
    if x.count() = 1
        qq_rr = Divide(r, x[0], y)
        z[0] = qq_rr.qq
        return qq_rr.rr
    end if
    rec = reciprocalWord(y)
    for i = z.count() - 1 to 0 step -1
        q_r = divWW(r, x[i], y, rec)
        z[i] = q_r.q
        r = q_r.r
    end for
    return r
end function

' q = ( x1 << _W + x0 - r)/y. m = floor(( _B^2 - 1 ) / d - _B)
function divWW(x1, x0, y, mm) as object
    s = nlz(y)
    if s <> 0
        x1 = x1 << s or x0 >> (64 - s)
        x0 <<= s
        y <<= s
    end if
    d = y
    h_l = Mul(mm, x1)
    t1 = h_l.hi
    t0 = h_l.lo
    s_c = Add(t0, x0, 0)
    c = s_c.carryOut
    s_c = Add(t1, x1, c)
    t1 = s_c.sum

    qq = t1
    h_l = Mul(d, qq)
    dq1 = h_l.hi
    dq0 = h_l.lo
    d_b = Subtract(x0, dq0, 0)
    r0 = d_b.diff
    b = d_b.borrowOut
    d_b = Subtract(x1, dq1, b)
    r1 = d_b.diff

    if r1 <> 0
        qq++
        r0 -= d
    end if

    if r0 >= d
        qq++
        r0 -= d
    end if

    q_r = {}
    q_r.q = qq
    q_r.r = (r0 >> s)

    return q_r
end function

' Subtract with borrow: diff = x - y - borrow
function Subtract(x, y, borrow) as object
    diff = x - y - borrow
    borrowOut = (((not x) and y) or (not (xor(x, y) and diff))) >> 63
    d_b = {}
    d_b.diff = diff
    d_b.borrowOut = borrowOut
    return d_b
end function

' Add with carry: sum = x + y + carry
function Add(x as longinteger, y as longinteger, carry as longinteger) as object
    sum = x + y + carry
    carryOut = ((x and y) or ((x or y) and not sum)) >> 63
    ? "carryOut " &h7FFFFFFF + 2
    s_c = {}
    s_c.sum = sum
    s_c.carryOut = carryOut
    return s_c
    ' ? "type: " type(x)
    ' sum64 = x + y + carry
    ' ? "type: " type(sum64)
    ' ? "sum64 = " sum64
    ' test = ((x and y) or ((x or y) and not sum64)) >> 20
    ' ? "type test: " type(test)
    ' ? "test: " test
end function

' full-width product of x and y
function Mul(x, y) as object
    mask32 = 1 << 32 - 1
    x0 = x and mask32
    x1 = x >> 32
    y0 = y and mask32
    y1 = y >> 32
    w0 = x0 * y0
    t = x1 * y0 + w0 >> 32
    w1 = t and mask32
    w2 = t >> 32
    w1 += x0 * y1
    hi = x1 * y1 + w2 + w1 >> 32
    lo = x * y
    h_l = {}
    h_l.hi = hi
    h_l.lo = lo
    return h_l
end function

' returns the reciprocal of the divisor
function reciprocalWord(d1)
    _B = (1 << 64)
    _M = _B - 1
    u = (d1 << nlz(d1))
    x1 = not u
    x0 = _M
    q_r = Divide(x1, x0, u)
    return q_r.q
end function

function nlz(x)
    return LeadingZeros64(x)
end function

function Divide(hi, lo, y) as object
    two32 = 1 << 32
    mask32 = two32 - 1
    if y = 0
        return invalid
    end if
    if y <= hi
        return invalid
    end if

    s = LeadingZeros64(y)
    y <<= s

    yn1 = y >> 32
    yn0 = y and mask32
    un32 = hi << s or lo >> (64 - 2)
    un10 = lo << s
    un1 = un10 >> 32
    un0 = un10 and mask32
    q1 = un32 / yn1
    rhat = un32 - q1 * yn1

    while q1 >= two32 or q1 * yn0 > two32 * rhat + un1
        q1--
        rhat += yn1
        if rhat >= two32
            exit while
        end if
    end while

    un21 = un32 * two32 + un1 - q1 * y
    q0 = un21 / yn1
    rhat = un21 - q0 * yn1

    while q0 >= 32 or q0 * yn0 > two32 * rhat + un0
        q0--
        rhat += yn1
        if rhat >= two32
            exit while
        end if
    end while

    q_r = {}
    q_r.q = q1 * two32 + q0
    q_r.r = (un21 * two32 + un0 - q0 * y) >> s

    return q_r
end function

function LeadingZeros64(x) as integer
    return 64 - Len64(x)
end function

function cmp(x as object, y as object) as integer
    l = x.count()
    n = y.count()
    r = 0

    if l <> n or l = 0
        if l < n
            r = -1
        else if l > n
            r = 1
        end if
        return r
    end if

    i = l - 1
    while i > 0 and x[i] = y[i]
        i--
    end while

    if x[i] < y[i]
        r = -1
    else if x[i] > y[i]
        r = 1
    end if

    return r
end function

function set(z as object, x as object) as object
    z.clear()
    for i = 0 to x.count() - 1
        z.push(x[i])
    end for
    return z
end function