import pandas as pd
import matplotlib.pyplot as plt
import sys

if len(sys.argv) != 10:
    print(
        "Usage: python RT_Q_conn.py tiers timeSpan wl output_name title_name x1 x2 timestamp_offset collectls"
    )
    sys.exit()

tiers = sys.argv[1].split(",")
timeSpan = sys.argv[2]
wl = sys.argv[3]
output_name = sys.argv[4]
title_name = sys.argv[5]
x1 = sys.argv[6]
x2 = sys.argv[7]
timestamp_offset = sys.argv[8]
collectls = sys.argv[9].split(",")

num_cores = 8

# Layout is very volatile, so if anything is added that changes the look first look as figsize, y in suptitile, and bbox_to_anchor in legend

# Create subplots
fig, axs = plt.subplots(
    len(tiers) * 5 + len(collectls),
    1,
    figsize=(10, 6 * (len(tiers) + len(collectls))),
    tight_layout=True,
)
fig.suptitle(title_name, y=0.995)

for i in range(len(tiers)):
    # Read data from CSV files
    df1 = pd.read_csv(f"{timeSpan}_{tiers[i]}_inout_wl{wl}-50ms-ALL.csv", header=0)
    df1.iloc[:, 0] = df1.iloc[:, 0] - int(timestamp_offset)

    df2 = pd.read_csv(
        f"{timeSpan}_{tiers[i]}_multiplicity_wl{wl}-50ms-ALL.csv", header=0
    )
    df2.iloc[:, 0] = df2.iloc[:, 0] - int(timestamp_offset)

    df3 = pd.read_csv(
        f"{timeSpan}_{tiers[i]}_inout_wl{wl}-50ms-LongReq1.csv", header=0
    )
    df3.iloc[:, 0] = df3.iloc[:, 0] - int(timestamp_offset)

    df4 = pd.read_csv(
        f"{timeSpan}_{tiers[i]}_responsetime_wl{wl}-50ms-ALL.csv", header=0
    )
    df4.iloc[:, 0] = df4.iloc[:, 0] - int(timestamp_offset)

    graph_subname = f"{tiers[i][tiers[i].find('-') + 1:]}-{wl}"

    # Plot RR
    df1_modified = df1.copy()
    df1_modified.iloc[:, 1] = df1_modified.iloc[:, 1] * 20
    df1_modified = df1_modified[
        (df1_modified.iloc[:, 0] >= int(x1)) & (df1_modified.iloc[:, 0] <= int(x2))
    ]
    axs[i * 5 + 0].plot(df1_modified.iloc[:, 0], df1_modified.iloc[:, 1])
    axs[i * 5 + 0].set_ylabel("RR [req/s]")
    axs[i * 5 + 0].set_xlim([int(x1), int(x2)])
    axs[i * 5 + 0].legend(
        [f"{graph_subname}-RR mean={df1_modified.iloc[:, 1].mean().round(4)}"],
        loc="upper right",
        frameon=False,
    )

    # Plot TP
    df1_modified = df1.copy()
    df1_modified.iloc[:, 2] = df1_modified.iloc[:, 2] * 20
    df1_modified = df1_modified[
        (df1_modified.iloc[:, 0] >= int(x1)) & (df1_modified.iloc[:, 0] <= int(x2))
    ]
    axs[i * 5 + 1].plot(df1_modified.iloc[:, 0], df1_modified.iloc[:, 2])
    axs[i * 5 + 1].set_ylabel("TP [req/s]")
    axs[i * 5 + 1].set_xlim([int(x1), int(x2)])
    axs[i * 5 + 1].legend(
        [f"{graph_subname}-TP mean={df1_modified.iloc[:, 2].mean().round(4)}"],
        loc="upper right",
        frameon=False,
    )

    # Plot QL
    df2_modified = df2.copy()
    df2_modified = df2_modified[
        (df2_modified.iloc[:, 0] >= int(x1)) & (df2_modified.iloc[:, 0] <= int(x2))
    ]
    axs[i * 5 + 2].plot(df2_modified.iloc[:, 0], df2_modified.iloc[:, 1])
    axs[i * 5 + 2].set_ylabel("QL [/s]")
    axs[i * 5 + 2].set_xlim([int(x1), int(x2)])
    axs[i * 5 + 2].legend(
        [f"{graph_subname}-QL mean={df2_modified.iloc[:, 1].mean().round(4)}"],
        loc="upper right",
        frameon=False,
    )

    # Plot LongReq
    df3_modified = df3.copy()
    df3_modified = df3_modified[
        (df3_modified.iloc[:, 0] >= int(x1)) & (df3_modified.iloc[:, 0] <= int(x2))
    ]
    axs[i * 5 + 3].plot(df3_modified.iloc[:, 0], df3_modified.iloc[:, 1])
    axs[i * 5 + 3].set_ylabel("Long Requests [#]")
    axs[i * 5 + 3].set_xlim([int(x1), int(x2)])
    axs[i * 5 + 3].legend(
        [f"{graph_subname}-Long-Reqs mean={df3_modified.iloc[:, 1].mean().round(4)}"],
        loc="upper right",
        frameon=False,
    )

    # Plot Response Time
    df4_modified = df4.copy()
    df4_modified = df4_modified[
        (df4_modified.iloc[:, 0] >= int(x1)) & (df4_modified.iloc[:, 0] <= int(x2))
    ]
    axs[i * 5 + 4].plot(df4_modified.iloc[:, 0], df4_modified.iloc[:, 1])
    axs[i * 5 + 4].set_ylabel("RT [s]")
    axs[i * 5 + 4].set_xlim([int(x1), int(x2)])
    axs[i * 5 + 4].legend(
        [f"{graph_subname}-RT mean={df4_modified.iloc[:, 1].mean().round(4)}"],
        loc="upper right",
        frameon=False,
    )

# CPU graphs

current_ax = len(tiers) * 5
for i in range(len(collectls)):
    df_cpu = pd.read_csv(collectls[i], header=0, sep="\s+")
    df_cpu.iloc[:, 0] = df_cpu.iloc[:, 0] - int(timestamp_offset)
    df_cpu = df_cpu[(df_cpu.iloc[:, 0] >= int(x1)) & (df_cpu.iloc[:, 0] <= int(x2))]

    for core in range(num_cores):
        column = 9 + core * 12
        axs[current_ax + i].plot(
            df_cpu.iloc[:, 0],
            df_cpu.iloc[:, column],
            label=f"core{core} mean={df_cpu.iloc[:, column].mean().round(4)}",
        )

    axs[current_ax + i].set_ylabel(f"VM{i}-CPU [%]")
    axs[current_ax + i].set_xlim([int(x1), int(x2)])
    axs[current_ax + i].legend(
        loc="lower center", bbox_to_anchor=(0.5, -0.7), ncol=3, frameon=False
    )

plt.savefig(output_name)
