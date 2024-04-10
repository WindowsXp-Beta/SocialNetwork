import pandas as pd
import matplotlib.pyplot as plt
import sys

if len(sys.argv) != 10:
    print(
        "Usage: python RT_Q_conn.py tiers timeSpan wl output_name title_name x1 x2 timestamp_offset types"
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
types = sys.argv[9].split(",")


for type in types:
    for tier in tiers:
        df1 = pd.read_csv(f"{timeSpan}_{tier}_inout_wl{wl}-50ms-{type}.csv", header=0)
        df1.iloc[:, 0] = df1.iloc[:, 0] - int(timestamp_offset)

        df2 = pd.read_csv(
            f"{timeSpan}_{tier}_queuelength_wl{wl}-50ms-{type}.csv", header=0
        )
        df2.iloc[:, 0] = df2.iloc[:, 0] - int(timestamp_offset)

        df3 = pd.read_csv(
            f"{timeSpan}_{tier}_responsetime_wl{wl}-50ms-{type}.csv", header=0
        )
        df3.iloc[:, 0] = df3.iloc[:, 0] - int(timestamp_offset)

        # The way we currently determine the amount of requst type could be finnicky as it depends on the multiplicity csv file
        fig, axs = plt.subplots(
            # 4 is number of graphs, - 1 to get rid of date_time
            4 * (len(df2.columns) - 1),
            1,
            figsize=(10, 6 * (len(df2.columns) - 1)),
            tight_layout=True,
        )
        fig.suptitle(title_name, y=0.995)

        set_of_index = set()

        # for each request type
        for i in range(1, len(df2.columns)):
            graph_subname = f"{df2.columns[i]}-{wl}"

            # make new df with only the columns we need of the time and current request type
            # Plot RR
            df1_modified = df1.iloc[:, [0, i * 2 - 1, i * 2]].copy()
            df1_modified.iloc[:, 1] = df1_modified.iloc[:, 1] * 20
            df1_modified = df1_modified[
                (df1_modified.iloc[:, 0] >= int(x1))
                & (df1_modified.iloc[:, 0] <= int(x2))
            ]

            axs[(i - 1) * 4 + 0].plot(
                df1_modified.iloc[:, 0], df1_modified.iloc[:, 1], label="RR"
            )
            axs[(i - 1) * 4 + 0].set_title(f"{graph_subname}-RR")
            axs[(i - 1) * 4 + 0].set_ylabel("RR [req/s]")
            axs[(i - 1) * 4 + 0].set_xlim([int(x1), int(x2)])
            axs[(i - 1) * 4 + 0].legend(
                [f"mean={df1_modified.iloc[:, 1].mean().round(4)}"],
                loc="upper right",
                frameon=False,
            )

            # Plot TP
            df1_modified = df1.iloc[:, [0, i * 2 - 1, i * 2]].copy()
            df1_modified.iloc[:, 2] = df1_modified.iloc[:, 2] * 20
            df1_modified = df1_modified[
                (df1_modified.iloc[:, 0] >= int(x1))
                & (df1_modified.iloc[:, 0] <= int(x2))
            ]

            axs[(i - 1) * 4 + 1].plot(
                df1_modified.iloc[:, 0], df1_modified.iloc[:, 2], label="TP"
            )
            axs[(i - 1) * 4 + 1].set_title(f"{graph_subname}-TP")
            axs[(i - 1) * 4 + 1].set_ylabel("TP [req/s]")
            axs[(i - 1) * 4 + 1].set_xlim([int(x1), int(x2)])
            axs[(i - 1) * 4 + 1].legend(
                [f"mean={df1_modified.iloc[:, 2].mean().round(4)}"],
                loc="upper right",
                frameon=False,
            )
            # Plot Queue Length
            df2_modified = df2.iloc[:, [0, i]].copy()
            df2_modified = df2_modified[
                (df2_modified.iloc[:, 0] >= int(x1))
                & (df2_modified.iloc[:, 0] <= int(x2))
            ]

            axs[(i - 1) * 4 + 2].plot(
                df2_modified.iloc[:, 0], df2_modified.iloc[:, 1], label="Queue Length"
            )
            axs[(i - 1) * 4 + 2].set_title(f"{graph_subname}-Queue Length")
            axs[(i - 1) * 4 + 2].set_ylabel("Queue Length [count]")
            axs[(i - 1) * 4 + 2].set_xlim([int(x1), int(x2)])
            axs[(i - 1) * 4 + 2].legend(
                [f"mean={df2_modified.iloc[:, 1].mean().round(4)}"],
                loc="upper right",
                frameon=False,
            )

            # Plot Response Time
            df3_modified = df3.iloc[:, [0, i]].copy()
            df3_modified = df3_modified[
                (df3_modified.iloc[:, 0] >= int(x1))
                & (df3_modified.iloc[:, 0] <= int(x2))
            ]

            axs[(i - 1) * 4 + 3].plot(
                df3_modified.iloc[:, 0], df3_modified.iloc[:, 1], label="Response Time"
            )
            axs[(i - 1) * 4 + 3].set_title(f"{graph_subname}-Response Time")
            axs[(i - 1) * 4 + 3].set_ylabel("Response Time [ms]")
            axs[(i - 1) * 4 + 3].set_xlim([int(x1), int(x2)])
            axs[(i - 1) * 4 + 3].legend(
                [f"mean={df3_modified.iloc[:, 1].mean().round(4)}"],
                loc="upper right",
                frameon=False,
            )

        plt.savefig(f"{tier}_{type}_{output_name}")
        plt.clf()
