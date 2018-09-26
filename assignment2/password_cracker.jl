using SHA
using Dates

function hash(password::String, salt::String)
    bytes2hex(sha256(string("potplantspw", password, salt)))[1:32]
end

function hash_eq(password::String, salt::String, hash_value::Array{UInt8,1})::Bool
    hash_quess = sha256(string("potplantspw", password, salt))
    # Test equality between hash_quess and hash_value.
    for i in 1:16
        if hash_quess[i] != hash_value[i]
            return false
        end
    end
    return true
end

# Test with student data
function test(test_password, test_salt, test_hash)
    hash(test_password, test_salt) == test_hash || error("Something is wrong.")
    test_hash_bytes = hex2bytes(test_hash)
    hash_eq(test_password, test_salt, test_hash_bytes) || error("hash_eq is not working.")

    @time hash(test_password, test_salt) == test_hash
    @time hash_eq(test_password, test_salt, test_hash_bytes)
end

const student_password = "knEeGPyr"
const student_salt = "d3bc139dafa7d4e9"
const student_hash = "7a00b42ac911a8603dd4cdbba662cdf2"
const student_hash_bytes = hex2bytes("7a00b42ac911a8603dd4cdbba662cdf2")
println("Testing student password, salt and hash.")
test(student_password, student_salt, student_hash)

# Benchmark
function benchmark(iterations::Int)
    for i in 1:iterations
        hash_eq(student_password, student_salt, student_hash_bytes)
    end
end

benchmark(1)
iterations=10^6
println("Time for ", iterations, " iteration.")
@time benchmark(iterations)

# Load userdata in format: username, salt, hash.
# Values are separated by tab '\t'.
const userdata = map.(String, split.(readlines("userdata.txt"), '\t'))

# load common words from /usr/share/dict/...
# const word_list = "/usr/share/dict/words"

# const word_list = "/mnt/737e9ed1-8932-449f-85af-6d903551da56/Downloads/realhuman_phill.lst"

# 1212356398 words, takes around 15 minutes to run
const word_list = "/mnt/737e9ed1-8932-449f-85af-6d903551da56/Downloads/realuniq.lst"

# Username that we have already cracked
const found = Set(["tim", "student", "elisha", "emina", "brooke", "emma", "david"])


# Return username and password if found.
function dictionary_attack(salt::String, hash_value::Array{UInt8,1}):: String
    for password in eachline(word_list)
        if hash_eq(password, salt, hash_value)
            return password
        end
    end
    return ""
end


# Password cracker
function cracker()
    for (username, salt, hash_value) in userdata[16:end]
        # Skip usernames that we have already cracked
        if username ∈ found
            continue
        end

        time = Dates.Time(Dates.now())
        println(time, " Cracking: ", username)
        password = dictionary_attack(salt, hex2bytes(hash_value))
        if password != ""
            println(username, " ", password)
        end
    end
end

# cracker()
