import sys
import pandas as pd
from pathlib import Path

# Workload, csv, tiers, timespan
if len(sys.argv) != 5:
    print("Usage: python extract_queue_length.py timespan workload tiers types")
    sys.exit()

timespan = sys.argv[1]
workload = sys.argv[2]
tiers = sys.argv[3].split(",")  # tier = detailRT-{tier}
types = sys.argv[4].split(",")

for type in types:
    for tier in tiers:
        filename = Path(f"{timespan}_{tier}_inout_wl{workload}-50ms-{type}.csv")
        df = pd.read_csv(filename, header=0)
        num_request_types = (len(df.columns) - 1) // 2
        output_file = Path(
            f"{timespan}_{tier}_queuelength_wl{workload}-50ms-{type}.csv"
        )

        with open(output_file, "w") as f:
            headers = "date_time"
            request_types = []

            for i in range(num_request_types):
                parts = df.columns[i * 2 + 1].split("_")
                request_type = f"{parts[0]}_{parts[1]}"
                request_types.append(request_type)
                headers += f",{request_type}"

            f.write(headers)
            f.write("\n")

            previous_q_length = {}

            for request_type in request_types:
                previous_q_length[request_type] = 0

            for i in range(1, len(df), 1):
                line = f"{df['date_time'][i] : .6f}"

                for request_type in request_types:
                    queue_length = (
                        previous_q_length[request_type]
                        + df[f"{request_type}_start"][i]
                        - df[f"{request_type}_end"][i]
                    )
                    previous_q_length[request_type] = queue_length
                    line += f",{queue_length}"

                line += "\n"
                f.write(line)
