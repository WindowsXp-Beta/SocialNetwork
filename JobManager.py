# ====================================
# SOCIAL NETWORK JOB MANAGER
# ====================================
# Created by Kyle Fry
# Georgia Institute of Technology
# Original Date: 2/22/24
# ====================================
# Version 1.0 (2/22/24):
# - Create driver code that passes user input to the master script (controller_setup.sh)

# Version 1.1 (2/29/24):
# - Add read feature for loading custom experiments

# Version 1.2 (3/6//24):
# - Add save feature when running default intializer

# Version 1.3 (3/14/24):
# - Add load feature to load from pre-saved custom jobs into the main controller script
# - Fix bugs with saving new custom jobs due to directory mis-match

# Version 1.4 (3/28/24):
# - Add remove feature for custom jobs into the main controller script
# - Add edit feature to allow users to make minor adjustments to current custom jobs
# - Allow users to chain together jobs via a job queue

# Version 1.5 (4/4/24):
# - Edit job queueing logic for file management
# - Add delete custom job feature

# Version 1.6 (4/12/24):
# - Add docker and node dedication config editing when starting a job



import os, sys, subprocess

# !!!!! Make sure JobManager and controller_setup are in the same directory !!!!!
def callController(arguments):
    os.system('nano config/config.json')
    os.system('nano socialNetwork/docker-compose-swarm.yml.template')
    os.system('nano socialNetwork/scripts/dedicate.sh')
    command = f'./controller_setup.sh ' \
        f'--username {arguments[0]} ' \
        f'--private_ssh_key_path "{arguments[1]}" ' \
        f'--controller_node {arguments[2]} ' \
        f'--git_email {arguments[3]} ' \
        f'--swarm_node_number {arguments[4]} ' \
        f'--client_node_number {arguments[5]}'
    os.system(command)

def callControllerQueue(job_queue):
    os.system('nano config/config.json')
    os.system('nano socialNetwork/docker-compose-swarm.yml.template')
    os.system('nano socialNetwork/scripts/dedicate.sh')
    for job in job_queue:
        command = f'./controller_setup.sh ' \
                  f'--username {job[0]} ' \
                  f'--private_ssh_key_path "{job[1]}" ' \
                  f'--controller_node {job[2]} ' \
                  f'--git_email {job[3]} ' \
                  f'--swarm_node_number {job[4]} ' \
                  f'--client_node_number {job[5]}'
        print(f"Executing job: {command}")
        os.system(command)

def chain_jobs(job_inputs):
    # List current custom jobs
    custom_jobs = listCustomJobs()
    if not custom_jobs:
        print("No custom jobs to chain.")
        return

    job_sequence = input("Enter the job numbers you want to chain (e.g., 1 2 3): ")
    job_ids = job_sequence.split()

    # Ensure job_ids are valid
    valid_job_ids = [id for id in job_ids if id.isdigit() and 0 < int(id) <= len(custom_jobs)]

    # Map user selection to custom_jobs entries
    queued_jobs = [custom_jobs[int(id) - 1][1] for id in valid_job_ids]

    os.system('nano config/config.json')
    callControllerQueue(queued_jobs)

def listCustomJobs():
    JOB_DIR = "CustomJobs"
    job_dir = f"./{JOB_DIR}/jobs"
    job_list = []
    try:
        with open(job_dir, 'r') as file:
            job_num = file.read().strip()  # Read the number of jobs
            JOB_NUMS = int(job_num)
    except FileNotFoundError:
        print(f"File not found: {job_dir}")
        return []
    except ValueError:
        print("Invalid job number.")
        return []
    
    if JOB_NUMS == 0:
        print("No saved jobs!")
        return []
    
    for i in range(1, JOB_NUMS + 1):
        job_file_path = f"./{JOB_DIR}/job{i}"
        try:
            with open(job_file_path, 'r') as job_file:
                job_details = job_file.readlines()
                job_list.append((i, job_details))
                print(f"Job {i}:")
                for line in job_details:
                    print(f"    {line.strip()}")
        except FileNotFoundError:
            print(f"File not found: job{i}")
        except Exception as e:
            print(f"Error reading file job{i}: {e}")
    return job_list

def chain_jobs_direct():
    print("Listing available custom jobs for chaining...")
    custom_jobs = listCustomJobs()
    if not custom_jobs:
        print("No custom jobs to chain.")
        return

    job_sequence = input("Enter the job numbers you want to chain (e.g., 1 2 3): ")
    job_ids = job_sequence.split()

    valid_job_ids = [id for id in job_ids if id.isdigit() and 0 < int(id) <= len(custom_jobs)]

    queued_jobs = [custom_jobs[int(id) - 1][1] for id in valid_job_ids]

    os.system('nano config/config.json')
    callControllerQueue(queued_jobs)

def editCustomJob():
    print("Listing available custom jobs for editing...")
    custom_jobs = listCustomJobs()
    if not custom_jobs:
        print("No custom jobs available to edit.")
        return
    
    try:
        job_number = int(input("Enter the number of the job you wish to edit: "))
        job_path = f"./CustomJobs/job{job_number}"
        
        # Check if the file exists before attempting to open it
        if os.path.exists(job_path):
            # Open the selected job file in nano editor
            subprocess.run(['nano', job_path])
        else:
            print(f"No job found with number: {job_number}")
    except ValueError:
        print("Invalid input. Please enter a valid job number.")
    except Exception as e:
        print(f"An error occurred: {e}")

# Get user input for a default job if there are no arguments passed into JobManager
def defaultSetup():
    job_inputs = []
    add_another_job = 'y'

    while add_another_job.lower() == 'y':
        user_input = []
        print("Please enter the job details.")
        username = input("Enter your Cloudlab username: ")
        private_key_path = input("Enter the total path of the PRIVATE key used to SSH into Cloudlab nodes: ")
        controller_node = input("Enter the HOSTNAME of the desired controller node: ")
        git_email = input("Enter your GitHub email address: ")
        swarm_nodes = input("Enter the # of swarm nodes: ")
        client_nodes = input("Enter the # of client nodes: ")

        user_input = [username, private_key_path, controller_node, git_email, swarm_nodes, client_nodes]
        job_inputs.append(user_input)
        saveCustomJob([user_input])  # Save each job individually

        add_another_job = input("Do you want to add another job? (y/n): ")

    if len(job_inputs) > 1:
        chain_jobs(job_inputs)
    else:
        callController(user_input)

# Load job configurations for the specified directory (either preset or custom)
# preset = 1 // custom = 2
def loadSavedJobs(dir):
    JOB_DIR = "PresetJobs" if dir == 1 else "CustomJobs" if dir == 2 else None
    if JOB_DIR is None:
        print("Invalid directory choice.")
        return
    job_dir = f"./{JOB_DIR}/jobs"
    try:
        with open(job_dir, 'r') as file:
            job_num = file.read().strip()  # Read the number of jobs
    except FileNotFoundError:
        print(f"File not found: {job_dir}")
        return
    try:
        JOB_NUMS = int(job_num)
    except ValueError:
        print("Invalid job number.")
        return
    
    if JOB_NUMS == 0:
        print("No saved jobs!")
        return
    print(f"=========={JOB_DIR}==========")
    for i in range(1, JOB_NUMS + 1):
        job_file_path = f"./{JOB_DIR}/job{i}"
        try:
            with open(job_file_path, 'r') as job_file:
                print(f"job{i}:")
                for line in job_file:
                    print("    " + line.strip())
        except FileNotFoundError:
            print(f"File not found: job{i}")
        except Exception as e:
            print(f"Error reading file job{i}: {e}")
    job_to_load = input("Please choose which job to load: ")
    job_file_path = f"./{JOB_DIR}/job{job_to_load}"
    with open(job_file_path, 'r') as file:
        user_input = []
        for line in file:
            user_input.append(line.strip())
    callController(user_input)

# Save the user's input as a job via file management
def saveCustomJob(job_inputs):
    job_dir = './CustomJobs/jobs'
    try:
        with open(job_dir, 'r') as file:
            job_num = int(file.read().strip())
    except FileNotFoundError:
        print(f"File not found: {job_dir}")
        job_num = 0  # If the file doesn't exist, start from 0
    except ValueError:
        print("Error reading the job count. Resetting to 0.")
        job_num = 0
    
    for user_input in job_inputs:
        JOB_NUMS = job_num + 1
        file_name = f'./CustomJobs/job{JOB_NUMS}'
        with open(file_name, 'w') as file:
            for item in user_input:  # Write each detail on a new line
                file.write(f'{item}\n')
        job_num += 1  # Update for the next job

    # Update the total number of jobs
    with open(job_dir, 'w') as file:
        file.write(str(job_num))

def updateJobFilesAndCountAfterRemoval(removed_job_number):
    job_dir = './CustomJobs'
    total_jobs_file = f'{job_dir}/jobs'
    with open(total_jobs_file, 'r') as file:
        total_jobs = int(file.read().strip())
    
    # Renumber the files
    for i in range(removed_job_number + 1, total_jobs + 1):
        old_file = f'{job_dir}/job{i}'
        new_file = f'{job_dir}/job{i - 1}'
        os.rename(old_file, new_file)
    
    # Update the total job count
    with open(total_jobs_file, 'w') as file:
        file.write(str(total_jobs - 1))

# Remove a defined customed Job
def removeCustomJob():
    print("Listing available custom jobs for removal...")
    custom_jobs = listCustomJobs()  # Ensure this function returns a list of job IDs or an empty list if no jobs are available
    if not custom_jobs:
        print("No custom jobs available to remove.")
        return
    
    try:
        job_number = int(input("Enter the number of the job you wish to remove: "))
        
        # Validate the job number
        if job_number < 1 or job_number > len(custom_jobs):
            print("Invalid job number. Please select a valid job.")
            return
        
        job_path = f"./CustomJobs/job{job_number}"
        
        # Remove the specified job file
        if os.path.exists(job_path):
            os.remove(job_path)
            print(f"Job {job_number} has been successfully removed.")
            
            # Update remaining job files and job count
            updateJobFilesAndCountAfterRemoval(job_number)
        else:
            print(f"Job {job_number} does not exist.")
    except ValueError:
        print("Invalid input. Please enter a numerical job number.")


if not (len(sys.argv) > 1):
    defaultSetup()
elif (sys.argv[1] == '-preset'):
    loadSavedJobs(1)
elif (sys.argv[1] == '-custom'):
    loadSavedJobs(2)
elif (sys.argv[1] == '-remove'):
    removeCustomJob()
elif sys.argv[1] == '-chain':
    custom_jobs = listCustomJobs()
    if custom_jobs:
        chain_jobs_direct()
elif sys.argv[1] == '-edit':
    editCustomJob()
else:
    print("ERROR: Unknown argument into JobManager")
    print("USAGE: JobManager.py [-p/-c/(none)] // -p: Pre-defined Setup / -c: Custom Setup")