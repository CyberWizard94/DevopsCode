a=input("please enter a number")
value=input("please enter a number you want to match")

b=list(a)

for i in b:
    if i == value:
        print("variable is present")
    else:
        print("variable is not present")