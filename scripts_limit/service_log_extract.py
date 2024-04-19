from pathlib import Path
import re
import subprocess
import sys

log_paths = [
    Path("log_post-storage-service.log"),
    Path("log_home-timeline-service.log"),
]

results = subprocess.run(
    ["grep", "Total number of clients for this experiment", "index.html"],
    capture_output=True,
)
if results.returncode != 0:
    print(f"Error: {results.stderr.decode()}")
    sys.exit(1)

workload = results.stdout.decode().split(": ")[1].split("<")[0]


def extract_data_from_log(log_file: Path) -> None:
    name = log_file.stem.split("_")[1]
    with open(log_file) as f, open(f"detailRT-{name}_wl{workload}.csv", "w") as w:
        w.write("start_time,end_time,request_type,response_time\n")
        for line in f:
            # start time, end time, request type, response time
            start_time, end_time = re.findall(
                r"(?:conn_)?(?:start|end)time=(\d+)", line
            )
            request_type = re.search(r" [A-Za-z]+2([A-Za-z]+-?[A-Za-z]+) ", line).group(
                1
            )

            w.write(
                f"{start_time},{end_time},{request_type},{int(end_time) - int(start_time)}\n"
            )


for log in log_paths:
    extract_data_from_log(log)
