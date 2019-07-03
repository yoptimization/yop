function YopAssert(expression, errorMessage)
message = ['Yop: ', errorMessage];

if expression == true
    assert(true, message)
    
elseif expression == false
    assert(false, message)
    
else
    assert(false, 'Yop: Wrong use of function "YopAssert"');
end
    
end