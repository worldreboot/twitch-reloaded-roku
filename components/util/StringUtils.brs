sub numberToText(number as Object) as Object
    result = ""
    if number < 1000
          result = number.toStr()
    else if number < 1000*1000
          n = (number/1000).toStr()
          ' Regex: any numbers with a dot and a decimal different from 0 OR any amount of numbers (stops at the dot). In that order.
          r = CreateObject("roRegex", "([0-9]+\.[1-9])|([0-9]+)", "") 
          result = r.Match(n)[0] + "K"
     else 
          n = (number/1000*1000).toStr()
          r = CreateObject("roRegex", "([0-9]+\.[1-9])|([0-9]+)", "") 
          result = r.Match(n)[0] + "M"
    end if
    return result
end sub