using SHA
using Dates

function hash(password::String, salt::String)
    bytes2hex(sha256(string("potplantspw", password, salt)))[1:32]
end

function hash_eq(password::String, salt::String, hash_value::Array{UInt8,1})::Bool
    hash_quess = sha256(string("potplantspw", password, salt))
    # Test equality between hash_quess and hash_value.
    # TODO: hash_quess == hash_value ? is the performance the same?
    for i in 1:16
        if hash_quess[i] != hash_value[i]
            return false
        end
    end
    return true
end

# Test with student data
function test()
    student_password = "knEeGPyr"
    student_salt = "d3bc139dafa7d4e9"
    student_hash = "7a00b42ac911a8603dd4cdbba662cdf2"

    hash(student_password, student_salt) == student_hash || error("Something is wrong.")
    student_hash_hex = hex2bytes(student_hash)
    hash_eq(student_password, student_salt, student_hash_hex) || error("hash_eq is not working.")

    @time hash(student_password, student_salt) == student_hash
    @time hash_eq(student_password, student_salt, student_hash_hex)
end

test()

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

cracker()
