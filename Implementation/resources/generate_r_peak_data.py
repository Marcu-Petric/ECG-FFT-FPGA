
def generate_rpeak_data():
    
    data = []
    data.extend(["00000000"] * 50)
    
    data.extend([
        "00000000",
        "00010000",
        "00020000",
        "00030000",
        "00040000",
        "00050000",
        "00100000",
        "00200000",
        "00300000",
        "00150000",
        "00080000",
        "00040000",
        "00020000",
        "00010000",
        "00000000"
    ])

    data.extend(["00000000"] * 50)

    
    data.extend([
        "00010000",
        "00020000",
        "00030000",
        "00040000",
        "00050000",
        "00100000",
        "00200000",
        "00300000",
        "00150000",
        "00080000",
        "00040000",
        "00020000",
        "00010000",
        "00000000"
    ])

    data.extend(["00000000"] * 50)

    
    with open('./resources/input_rpeak_data.txt', 'w') as f:
        for value in data:
            f.write(value + '\n')


generate_rpeak_data()
