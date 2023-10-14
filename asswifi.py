from string import printable
import datetime
import sys

def unix_timestamp(year, month, day, hour, minute, second):
    dt = datetime.datetime(year, month, day, hour, minute, second)
    return int(dt.timestamp())

#Convert Windows netsh signal percentage to dbm rssi
def convert_signal_percentage(signal_percentage):
    return (signal_percentage / 2 ) - 100

#takes list of string, each entry in list is one line
def extract_bssid_data(bulk_data):
    output_lines = []
    output_dicts = []

    current_ssid = ""
    current_bssid = ""
    current_channel = ""
    current_band = ""
    current_type = ""
    current_signal = ""

    prev_ssid = ""

    for line in bulk_data:

        # print data once one BSSID is read

        #Reminder of the structure:
        #~SSID 
        #~    BSSID 
        #~    BSSID 
        #~    BSSID 
        #~SSID 
        #~    BSSID 
        #~    BSSID 
        
        #because the SSID line overwrites the current ssid, to get the corect SSID here it's the "prev" SSID
        if (line.startswith("    BSSID 1") or line.startswith('X'*33)):
            output_lines.append(f"{prev_ssid},{current_bssid},{current_type},{current_band},{current_channel},{current_signal}")
            output_dicts.append({"ssid":prev_ssid, "bssid":current_bssid, "standard":current_type, "band":current_band, "channel":current_channel, "rssi":current_signal})
        #but the subsequent lines do not overwrite the current ssid, so to get the correct SSID here it's the "current" SSID
        elif line.startswith("    BSSID "):
            output_lines.append(f"{current_ssid},{current_bssid},{current_type},{current_band},{current_channel},{current_signal}")
            output_dicts.append({"ssid":current_ssid, "bssid":current_bssid, "standard":current_type, "band":current_band, "channel":current_channel, "rssi":current_signal})

        # store data to vars
        if line.startswith("SSID "):
            prev_ssid = current_ssid
            current_ssid = line[9:].strip()

        elif line.startswith("    BSSID "):
            current_bssid = line[30:].strip()
        
        elif line.startswith("         Signal             :"):
            try:
                current_signal = str(int(convert_signal_percentage(int(line[30:].strip().replace("%","")))))
            except:
                current_signal = ""

        elif line.startswith("         Channel            :"):
            current_channel = line[30:].strip()

        elif line.startswith("         Band               :"):
            current_band = line[30:].strip()

        elif line.startswith("         Radio type         :"):
            current_type = line[30:].strip()

    return output_dicts


def extract_interface_data(bulk_data):
    desc = ""
    ssid = ""
    bssid = ""


    for line in bulk_data:
        if line.startswith("    Description            : "):
            desc = line[29:]
        if line.startswith("    SSID                   : "):
            ssid = line[29:]
        if line.startswith("    BSSID                  : "):
            bssid = line[29:]
    
    return {"description":desc.strip(), "ssid":ssid.strip().replace('"','-').replace(",","-"), "bssid":bssid.strip()}


def extract_gps_data(bulk_data):
    latitude = ""
    longitude = ""
    accuracy = ""


    for line in bulk_data:
        if line.startswith("Latitude           : "):
            latitude = line[21:]
        if line.startswith("Longitude          : "):
            longitude = line[21:]
        if line.startswith("HorizontalAccuracy : "):
            accuracy = line[21:]
    
    return {"latitude":latitude.strip(), "longitude":longitude.strip(), "accuracy":accuracy.strip()}


def extract_average_ping_latency(bulk_data):
    times = []
    for line in bulk_data:
        if line.startswith("Pinging"):
            pass
        try:
            timestr = str(line.strip().split(" ")[4])
            timestr = timestr[5:]
            timestr = timestr[:-2]
            times.append(int(timestr))
        except:
            pass


    
    if len(times) == 0:
        return 99999
    else:
        return sum(times)/len(times)


def extract_ip_addr(bulk_data):
    ip = ""

    for line in bulk_data:
        if line.startswith("Content           : "):
            ip = line.strip()[20:]
            return ip
    
    return "None"


def extract_text_data_blocks(text_file_path):
    bssid_heading = "================BSSID INFORMATION================"
    interface_heading = "================INTERFACE INFORMATION================"
    ping_heading = "================PING TEST================"
    ip_heading = "================PUBLIC IP================"
    gps_heading = "================GPS INFORMATION================"
    end_heading = "================END OF AUTOMATICALLY CAPTURED DATA================"

    bssid_info = []
    interface_info = []
    gps_info = []
    ping_info = []
    ip_info = []

    current_section = ""

    with open(text_file_path, "r") as file:
        for raw_line in file:
            line = ''.join(char for char in raw_line if char in printable)
            if bssid_heading in line:
                current_section = "bssid"
            elif line.startswith(interface_heading):
                current_section = "interface"
            elif line.startswith(ping_heading):
                current_section = "ping"
            elif line.startswith(gps_heading):
                current_section = "gps"
            elif line.startswith(ip_heading):
                current_section = "ip"
            elif line.startswith(end_heading):
                break

            if current_section == "bssid":
                bssid_info.append(line)
            elif current_section == "interface":
                interface_info.append(line)
            elif current_section == "ping":
                ping_info.append(line)
            elif current_section == "gps":
                gps_info.append(line)
            elif current_section == "ip":
                ip_info.append(line)

    return {"bssid_bulk":bssid_info, "interface_bulk":interface_info, "ping_bulk":ping_info, "gps_bulk":gps_info, "ip_bulk":ip_info}



if __name__ == "__main__":

    print(f"in  = {sys.argv[1]}")
    print(f"out = {sys.argv[2]}")

    input_file_path = f"{sys.argv[1]}"
    output_file_path = f"{sys.argv[2]}".replace(".txt",".csv")

    input_file_name = input_file_path.split("\\")[-1]

    time_from_filename = input_file_name[:-4]

    time_pieces = time_from_filename.split("-")
    timestamp = unix_timestamp(int(time_pieces[0]), int(time_pieces[1]), int(time_pieces[2]), int(time_pieces[3]), int(time_pieces[4]), int(time_pieces[5]))

    #read data from file
    data_blocks = extract_text_data_blocks(input_file_path)
    bssid_data = extract_bssid_data(data_blocks['bssid_bulk'])
    gps_data = extract_gps_data(data_blocks['gps_bulk'])
    interface_data = extract_interface_data(data_blocks['interface_bulk'])
    ping_latency = extract_average_ping_latency(data_blocks['ping_bulk'])
    ip_addr = extract_ip_addr(data_blocks['ip_bulk'])
    
    # print(timestamp)
    # print(interface_data)
    # print(ping_latency)
    # print(ip_addr)
    
    #prepare file
    with open(output_file_path, 'w+') as outfile:
        header = "Timestamp, GPSLat, GPSLong, GPSAcc, SSID, BSSID, Standard, Frequency, Channel, RSSI (dBm), Public IP Address, Network Delay"
        outfile.write(f"{header}\n")

        for item in bssid_data:
            ip = ""
            latency = ""

            if interface_data['ssid'] == "uniwide" and item['bssid'] == interface_data['bssid']:
                ip = ip_addr
                latency = ping_latency

            output_line = f"{timestamp},{gps_data['latitude']},{gps_data['longitude']},{gps_data['accuracy']},{item['ssid']},{item['bssid']},{item['standard']},{item['band']},{item['channel']},{item['rssi']},{ip},{latency}"

            outfile.write(f"{output_line}\n")
            

        

