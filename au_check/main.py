import random


def check_au(group, au):
    is_found = bool(random.getrandbits(1))
    return is_found


def security_check(user):
    print(f"SECURITY check")
    is_cleared = bool(random.getrandbits(1))
    return is_cleared


def audit_check(user):
    print(f"AUDIT check")
    is_cleared = bool(random.getrandbits(1))
    return is_cleared


groups = ["group_1", "group_2", "group_3"]
user = "roger federer"

security_check_done = False
audit_check_done = False

security_cleared = False
audit_cleared = False

error_message_list = []

for group in groups:
    print(f"   ### checking for {group}..")

    # Automation Scope Check..
    if check_au(group, "automation au"):

        if not security_check_done:
            # Security Check..
            if check_au(group, "security au"):
                if security_cleared:
                    print(f"{user} is already security cleared")
                else:
                    if not security_check(user):
                        error_message_list.append(
                            f"Security check failed for the user - {group}"
                        )
                    else:
                        security_cleared = True

                    security_check_done = True
            else:
                print(f"Security check not required for {group}")
        else:
            print("Security check already done!")

        if not audit_check_done:
            # Audit check..
            if check_au(group, "audit au"):
                if audit_cleared:
                    print(f"{user} is already audit cleared")
                else:
                    if not audit_check(user):
                        error_message_list.append(
                            f"Audit check failed for the user - {group}"
                        )
                    else:
                        audit_cleared = True

                    audit_check_done = True
            else:
                print(f"Audit check not required for {group}")
        else:
            print("Audit check already done!")

    else:
        error_message_list.append(f"{group} is not under automation scope yet")

v_status = bool(not len(error_message_list))
v_message = "Successful" if v_status else ", ".join(error_message_list)

print(f"Validation Status: {v_status}")
print(f"Validation Message: {v_message}")
