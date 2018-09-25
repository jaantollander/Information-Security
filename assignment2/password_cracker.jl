using SHA

# https://docs.julialang.org/en/v1/stdlib/SHA/#SHA-1
# Hash function
function hash(password::String, salt::String)
    bytes2hex(sha256(string("potplantspw", password, salt)))[1:32]
end

# Test with student data
function test()
    student_password = "knEeGPyr"
    student_salt = "d3bc139dafa7d4e9"
    student_hash = "7a00b42ac911a8603dd4cdbba662cdf2"
    hash(student_password, student_salt) == student_hash || error("Something is wrong.")
end

test()

# Load userdata in format: username, salt, hash.
# Values are separated by tab.
userdata = readlines("userdata.txt")
#TODO: split value by tab

# TODO: load common words from /usr/share/dict/...
words = readlines("/usr/share/dict/cracklib-small")

# TODO: start cracking
