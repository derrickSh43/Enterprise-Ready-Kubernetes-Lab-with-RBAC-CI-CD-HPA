from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
import json
from datetime import datetime
import os

# Scopes for Google Tasks API
SCOPES = ['https://www.googleapis.com/auth/tasks']

def authenticate():
    creds = None
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    if not creds or not creds.valid:
        flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
        creds = flow.run_local_server(port=0)
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
    return creds

def create_task_list(service, title):
    tasklist = {'title': title}
    result = service.tasklists().insert(body=tasklist).execute()
    return result['id']

def find_task_list(service, title):
    tasklists = service.tasklists().list().execute()
    for tasklist in tasklists.get('items', []):
        if tasklist['title'] == title:
            return tasklist['id']
    return None

def main():
    creds = authenticate()
    service = build('tasks', 'v1', credentials=creds)

    # Find or create task list
    task_list_title = 'GKE Lab Tasks'
    task_list_id = find_task_list(service, task_list_title)
    if not task_list_id:
        task_list_id = create_task_list(service, task_list_title)

    # Load tasks from JSON
    with open('gke_lab_tasks.json', 'r') as f:
        tasks = json.load(f)['tasks']

    # Add tasks to Google Tasks
    for task in tasks:
        task_body = {
            'title': task['title'],
            'notes': task['notes'],
            'due': f"{task['due']}T00:00:00Z"
        }
        service.tasks().insert(tasklist=task_list_id, body=task_body).execute()
        print(f"Added task: {task['title']}")

if __name__ == '__main__':
    from google.oauth2.credentials import Credentials
    main()
