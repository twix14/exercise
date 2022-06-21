import getpass, re

def get_group_id(user):
  group_id = -1

  file = open("/etc/passwd", "r")
  for line in file:
    if line.startswith(user + ":"):
      elems = line.split(":")
      group_id = elems[3]
      break
  return group_id 

def get_users_of_group(group_id):
  users = []

  file = open("/etc/group", "r")
  for line in file:
    if re.findall("^.*:.*:.*:.*$", line):
      elems = line.split(":") 
      if elems[2] == group_id:
        users = elems[3].split(",")
        break
  return users

# https://stackoverflow.com/questions/842059/is-there-a-portable-way-to-get-the-current-username-in-python
myself = getpass.getuser()

group_id = get_group_id(myself)
if group_id == -1: 
  raise Exception("group id not found for current user!")

same_group_users = get_users_of_group(group_id)
if not same_group_users:
  raise Exception("group id " + group_id + " of current user not found in /etc/group")

print("users of the same group as the current user:")
for user in same_group_users:
  print(user)