import argparse
from faker import Faker

def fill_template(template, mapping):
	res = template
	for key, value in mapping.items():
		res = res.replace("{%s}" % key, value)
	return res

parser = argparse.ArgumentParser(description='Populate a ldif format to be imported into LDAP server.')
parser.add_argument('--users-count', metavar='N', dest="users_count", 
						type=int, nargs=1, default=5,
                    	help='Provide number of users to populate')
parser.add_argument('--domain', metavar='domain', dest="domain", nargs=1, type=str,
                    	help='Provide a domiain in your LDAP to populate',required=True)

parser.add_argument('--output', metavar='<filename>', dest="output_file_name", nargs=1,
                    	default="users",help='Provide an output file name')

args = parser.parse_args()
print(args.users_count)
users_count = args.users_count
print(args.domain)
domain, postfix = args.domain[0].split(".")
output_file_name = args.output_file_name

output_file = open(output_file_name + ".ldif", "w+")

groups_template = open('groups.template', 'r').read()
user_template = open('user.template', 'r').read()

groupDetailMappings = {
		"domainName": domain,
		"domainPostfix": postfix,
}

groups_filled_template = fill_template(groups_template, groupDetailMappings)
output_file.write(groups_filled_template)

for i in range(0, users_count):
	fakeUserDetails = Faker()
	userDetailsMappings = {
		"username": fakeUserDetails.user_name(),
		"domainName": domain,
		"domainPostfix": postfix,
		"lastName": fakeUserDetails.last_name(),
		"givenName": fakeUserDetails.first_name(),
		"uidNumber": str(11000 + i)

	}

	user_filled_template = fill_template(user_template, userDetailsMappings)
	output_file.write(user_filled_template)

output_file.close()

