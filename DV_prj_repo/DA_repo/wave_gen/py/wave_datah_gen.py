import math

def generate_waveforms(filename="wave_data.txt"):
    depth = 256
    bits = 16
    max_val = (2**bits) - 1  # 65535 (16'hFFFF)
    
    # 存储波形数据的字典
    waveforms = [
        {"name": "Sine Wave", "range": "0-255", "data": []},
        {"name": "Triangle Wave", "range": "256-511", "data": []},
        {"name": "Sawtooth Wave", "range": "512-767", "data": []},
        {"name": "Square Wave", "range": "768-1023", "data": []}
    ]

    # 1. 生成正弦波 (Sine Wave)
    # 映射范围 [-1, 1] 到 [0, 65535]
    for i in range(depth):
        val = int(round((max_val / 2) * (1 + math.sin(2 * math.pi * i / depth))))
        waveforms[0]["data"].append(val)

    # 2. 生成三角波 (Triangle Wave)
    # 前128点上升，后128点下降
    for i in range(depth):
        if i < 128:
            val = int(round(i * (max_val / 128)))
        else:
            val = int(round(max_val - (i - 128) * (max_val / 128)))
        waveforms[1]["data"].append(val)

    # 3. 生成锯齿波 (Sawtooth Wave)
    # 线性上升从 0 到 65535
    for i in range(depth):
        val = int(round(i * (max_val / (depth - 1))))
        waveforms[2]["data"].append(val)

    # 4. 生成方波 (Square Wave)
    # 前128点高电平，后128点低电平
    for i in range(depth):
        val = max_val if i < 128 else 0
        waveforms[3]["data"].append(val)

    # 写入文件
    with open(filename, "w", encoding="utf-8") as f:
        current_addr = 0
        for wave in waveforms:
            # 打印波形名称和地址范围
            f.write(f"// {wave['name']} [{wave['range']}]\n")
            
            for val in wave["data"]:
                # 限制范围确保不溢出
                val = max(0, min(max_val, val))
                # 格式化为4位大写16进制
                hex_str = f"{val:04X}"
                # 按照格式要求：[16进制数据][空格][空格][//][空格][10进制地址数]
                f.write(f"{hex_str}  // {current_addr}\n")
                current_addr += 1
            
            # 交界点处额外换行
            f.write("\n")

    print(f"成功生成波形文件: {filename}")

if __name__ == "__main__":
    generate_waveforms()