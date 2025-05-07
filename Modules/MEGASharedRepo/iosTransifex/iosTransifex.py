#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json, os, sys, re, subprocess, time, argparse, datetime
from pyexpat import ExpatError
from xml.dom.minidom import parseString
from threading import Thread

version = sys.version_info.major
if version == 2:
    from urllib2 import Request, urlopen, install_opener, build_opener, HTTPRedirectHandler, HTTPError
    reload(sys)
    sys.setdefaultencoding('utf8')
else:
    from urllib.request import Request, urlopen, install_opener, build_opener, HTTPRedirectHandler
    from urllib.error import HTTPError

transifex_token = os.getenv("TRANSIFEX_TOKEN")
gitlab_token = os.getenv("GITLAB_TOKEN")
transifex_bot_token = os.getenv('TRANSIFEX_BOT_TOKEN')
transifex_bot_url = os.getenv('TRANSIFEX_BOT_URL')
transifex_project_name = "ios-35"
git_id = 193
git_branch = "develop"
prod_path = "Modules/Presentation/MEGAL10n/Sources/MEGAL10n/Resources/"
is_lib = False

config_file = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'transifexConfig.json')
if os.path.exists(config_file):
    transifex_config_file = open(config_file, "r")
    content = transifex_config_file.read()
    transifex_config_file.close()
    transifex_config = json.loads(content)

    transifex_token = transifex_config.get('apiToken') or transifex_token
    gitlab_token = transifex_config.get('gitLabToken') or gitlab_token
    transifex_bot_token = transifex_config.get('botToken') or transifex_bot_token
    transifex_bot_url = transifex_config.get('botUrl') or transifex_bot_url
    transifex_project_name = transifex_config.get('projectName') or transifex_project_name
    git_id = transifex_config.get('gitId') or git_id
    git_branch = transifex_config.get('gitDefaultBranch') or git_branch
    prod_path = transifex_config.get('langStorePath') or prod_path
    is_lib = transifex_config.get('lib') or is_lib

if not transifex_token:
    print("Error: Missing transifex token.")
    sys.exit(1)

if not gitlab_token:
    print("Error: Missing gitlab token.")
    sys.exit(1)

BASE_URL = "https://rest.api.transifex.com"
GITLAB_URL = "https://code.developers.mega.co.nz/api/v4/projects/" + str(git_id) + "/repository/files/$pathBase.lproj%2F$file/raw?ref=" + git_branch
PROJECT_ID = "o:meganz-1:p:" + transifex_project_name
STORES_IOS_ID = "o:meganz-1:p:stores:r:app_store_ios"
STORES_IOS_VPN_ID = "o:meganz-1:p:mega-vpn-ios:r:app_store_ios_vpn"
STORES_IOS_PWD_ID = "o:meganz-1:p:password-manager-ios:r:"
HEADER = {
    "Authorization": "Bearer " + transifex_token,
    "Content-Type": "application/vnd.api+json"
}
REMAPPED_CODE = {
    "zh_CN": "zh-Hans",
    "zh_TW": "zh-Hant",
}
I18N_FORMAT = ["STRINGS", "STRINGSDICT"]

# Wrapper to read content from file
def file_get_contents(filepath):
    with open(filepath, "r") as file:
        content = file.read()
    return content

DOWNLOAD_FOLDER = os.getcwd() + "/download/"
git_path = os.getcwd()

# Read in the config file to determine the RESERVED_RESOURCES values.
def parse_strings_config(path):
    global git_path
    if not os.path.exists(path):
        print("ERROR: Missing configuration file for strings resources")
        sys.exit(1)

    config = file_get_contents(path)
    config = [line for line in config.split('\n') if line.strip()]
    map = {}
    for line in config:
        tmp = line.split(" ")
        if len(tmp) == 2 and "-" not in tmp[0]:
            if os.path.exists(git_path + "/" + tmp[1]):
                map[tmp[0]] = tmp[1]
            else:
                print("ERROR: The specified folder does not exist. " + git_path + "/" + tmp[1])
        else:
            print("ERROR: Invalid configuration: " + line)
    if len(map.keys()) == 0:
        print("ERROR: No valid configurations")
        sys.exit(1)
    return map

config_file = transifex_project_name + "-resources.conf"
if is_lib:
    config_file = "lib-resources.conf"
config_map = parse_strings_config(os.path.join(os.path.dirname(os.path.realpath(__file__)), config_file))
RESERVED_RESOURCES = config_map.keys()

if "/transifex" in git_path:
    git_path = git_path + "/.."
PROD_FOLDER = git_path + "/" + prod_path
if not os.path.isdir(PROD_FOLDER):
    os.makedirs(PROD_FOLDER)
if not os.path.isdir(DOWNLOAD_FOLDER):
    os.makedirs(DOWNLOAD_FOLDER)

resources = {}
language_cache = {}
base_strings = []
branch_strings = {}
user_cache = {}
# re.sub compatible version of PHP regex: /^[\pZ\pC]+|[\pZ\pC]+$/u as \p is not supported
unicode_regex = re.compile('^[\u0000-\u0020\u007F-\u00A0\u00AD\u0600-\u0605\u061C\u06DD\u070F\u08E2\u1680\u180E\u2000-\u200F\u2028-\u202F\u205F-\u2064\u2066-\u206F\u3000\uFEFF\uFFF9-\uFFFB\U000110BD\U000110CD\U00013430-\U00013438\U0001BCA0\U0001BCA3\U0001D173-\U0001D17A\U000E0001\U000E0020-\U000E007F]+|[\u0000-\u0020\u007F-\u00A0\u00AD\u0600-\u0605\u061C\u06DD\u070F\u08E2\u1680\u180E\u2000-\u200F\u2028-\u202F\u205F-\u2064\u2066-\u206F\u3000\uFEFF\uFFF9-\uFFFB\U000110BD\U000110CD\U00013430-\U00013438\U0001BCA0\U0001BCA3\U0001D173-\U0001D17A\U000E0001\U000E0020-\U000E007F]+$', re.UNICODE)
xml_tag_regex = re.compile(r'<[^[sd][^>]*>')
jira_id = ""

# Call this function to create a new resource in Transifex for the current git branch and create a local file for string additions/edits
# Or call this function to create a new feature resource in Transifex with the given resource name
def run_branch(resource, is_feature = False):
    branch = get_branch_name()
    if branch == False and is_feature == False:
        print("Error: Not allowed to create resources for develop/master branch")
        return False
    if is_feature:
        resource_name = resource
    else:
        resource_name = resource + "-" + branch
    is_plurals = "Plurals" in resource
    if is_plurals:
        i18n_format = I18N_FORMAT[1]
    else:
        i18n_format = I18N_FORMAT[0]
    if does_resource_exist(resource_name):
        print("Resource " + resource_name + " already exists.")
        return None
    create_payload = {
        "data": {
            "attributes": {
                "name": resource_name,
                "slug": resource_name.lower()
            },
            "relationships": {
                "i18n_format": {
                    "data": {
                        "id": i18n_format,
                        "type": "i18n_formats",
                    },
                },
                "project": {
                    "data": {
                        "id": PROJECT_ID,
                        "type": "projects",
                    },
                },
            },
            "type": "resources",
        }
    }
    result = do_request(BASE_URL + "/resources", create_payload)
    if "errors" in result:
        print("Error: Resource " + resource_name + " was not created")
        print_error(result["errors"])
        return False
    print("Successfully created new resource " + resource_name)
    return True

# Call this function to download the resource to the specified folder
def run_download(resource, folder = DOWNLOAD_FOLDER):
    if folder != DOWNLOAD_FOLDER and not os.path.isdir(folder):
        os.makedirs(folder)
    if does_resource_exist(resource):
        print("Downloading " + resource)
        is_plurals = "Plurals" in resource
        content = resource_get_english(resource, is_plurals)
        if content:
            if folder == PROD_FOLDER:
                store_file(resource, process_as_download(content, is_plurals))
            else:
                file_path = folder + "/" + get_file_basename(resource)
                file_put_contents(file_path, content)
                print("File saved to " + file_path)
        else:
            print("Error: Failed to download resource " + resource)
    else:
        print("Error: Resource " + resource + " not found")

# Call this function to download each reserved resource to the Production folder
def run_fetch(merge = False, return_values = False):
    resources = get_resources()
    branch = get_branch_name()
    return_map = {}
    for resource in resources:
        resource_name = resources[resource]["name"]
        if resource_name in RESERVED_RESOURCES:
            if merge:
                if branch and does_resource_exist(resource_name + "-" + branch):
                    run_merge(resource_name, resource_name + "-" + branch)
                else:
                    run_download(resource_name, PROD_FOLDER)
            else:
                print("Downloading " + resource_name)
                is_plurals = "Plurals" in resource_name
                content = resource_get_english(resource_name, is_plurals)
                if content:
                    store_file(resource_name, process_as_download(content, is_plurals))
                    if return_values:
                        return_map[resource] = content
                else:
                    print("Error: Failed to download resource " + resource_name)
    if return_values:
        return return_map
    return True

# Call this function to download each reserved resource and each language to the Production folder
def run_export(merge = False, spec_resource = False):
    languages = get_languages()
    branch = ""
    if merge:
        if get_branch_name():
            branch = get_branch_name()
        else:
            print("Error: Cannot export and merge for a branch on master/develop")
            merge = False
    def export_resource_language(resource, language, en_file):
        if merge and does_resource_exist(resource + "-" + branch):
            run_merge(resource, resource + "-" + branch, language, languages[language]["code"])
            return
        is_plurals = "Plurals" in resource
        content = resource_get_language(resource, language, is_plurals)
        if content:
            code = languages[language]["code"]
            if code in REMAPPED_CODE:
                code = REMAPPED_CODE[code]
            if en_file:
                content = merge_strings(en_file, content, False, is_plurals, True)
            store_file(resource, process_as_download(content, is_plurals), code)
        else:
            print("Error: Failed to download resource " + resource + " in language " + languages[language]["name"])

    resources = get_resources()
    print("Exporting English")
    en = {}
    if spec_resource:
        if branch != "" and does_resource_exist(spec_resource + "-" + branch):
            run_merge(spec_resource, spec_resource + "-" + branch)
        elif does_resource_exist(spec_resource):
            run_download(spec_resource, PROD_FOLDER)
        else:
            print("Error: Resource does not exist")
            return False
    else:
        en = run_fetch(merge, True)
    threads = []
    for resource in resources:
        if resources[resource]["name"] in RESERVED_RESOURCES:
            if spec_resource and resources[resource]["name"] == spec_resource:
                print("Exporting languages for " + resources[resource]["name"])
                for id in languages.keys():
                    t = Thread(target=export_resource_language, args=(resources[resource]["name"], id, False))
                    threads.append(t)
                    t.start()
            elif not spec_resource:
                print("Exporting languages for " + resources[resource]["name"])
                for id in languages.keys():
                    t = Thread(target=export_resource_language, args=(resources[resource]["name"], id, en[resource]))
                    threads.append(t)
                    t.start()

    for thread in threads:
        thread.join()
    print("Export finished")
    return True

# Call this function to upload the strings file supplied as the base file of the resource it is named for
def run_upload(file_content, resource, branch):
    is_plurals = "Plurals" in resource
    if not validate_file(file_content, is_plurals):
        print("Error: Invalid file content")
        return False
    if branch:
        resource_key = does_resource_exist(resource + "-" + branch)
        if resource_key == False:
            if run_branch(resource) == False:
                print("Error: Cannot upload as the branch does not exist")
                return False
            else:
                resource_key = does_resource_exist(resource + "-" + branch, True)
    else:
        resource_key = does_resource_exist(resource)
    if resource_key:
        if branch:
            gitlab_resource_file = gitlab_download(resource)
            if gitlab_resource_file:
                resource = resource + "-" + branch
                gitlab_map = content_to_map(gitlab_resource_file, False, is_plurals)
                file_map = content_to_map(file_content, False, is_plurals) # This needs to be in the same parsed state as the gitlab map i.e: download content not the upload content
                diff_map = {key: str for key, str in file_map.items() if key not in gitlab_map or not strings_equal(gitlab_map[key], str, is_plurals)}
                if missing_developer_comments(diff_map, is_plurals):
                    print("Error: Uploading branch resource without developer comments is not allowed. Please provide the comments and try again.")
                    return False
                file_content = map_to_content(diff_map, is_plurals)
            else:
                print("Error: Failed to download gitlab file")
                return False
        now = int(datetime.datetime.now(datetime.timezone.utc).timestamp()) - 30
        global jira_id
        while re.search("^[A-Z]{2,4}-\d+", jira_id) == None:
            jira_id = input("Please enter the JIRA ticket ID for this branch. e.g: IOS-1234: ")
        print("Uploading file")
        if resource_put_english(resource_key, process_as_upload(file_content, is_plurals)):
            print("Upload completed")
            time.sleep(5)
            run_lock(resource, now)
            return True
        else:
            print("Error: Failed to upload file for resource " + resource)
    else:
        print("Error: Invalid resource specified")

# Call this function to merge the resource and branch resource and put the result in the PROD_FOLDER
def run_merge(resource, branch_resource, language = False, lang_code = "Base"):
    if does_resource_exist(resource) and does_resource_exist(branch_resource):
        is_plurals = "Plurals" in resource
        print("Downloading and merging " + resource + " with " + branch_resource)
        if language:
            resource_content = resource_get_language(resource, language, is_plurals)
        else:
            resource_content = resource_get_english(resource, is_plurals)
        if resource_content:
            if language:
                branch_resource_content = resource_get_language(branch_resource, language, is_plurals)
            else:
                branch_resource_content = resource_get_english(branch_resource, is_plurals)
            if branch_resource_content:
                gitlab_resource_content = gitlab_download(resource, lang_code)
                if gitlab_resource_content or "LTHPasscodeViewController" in resource:
                    print("Downloads complete. Merging")
                    merge_content = merge_strings(resource_content, branch_resource_content, False, is_plurals)
                    if "LTHPasscodeViewController" not in resource:
                        merge_content = merge_strings(gitlab_resource_content, merge_content, False, is_plurals)
                    if merge_content:
                        store_file(resource[:resource.find("-") if "-" in resource else len(resource)], merge_content, lang_code)
                        return True
                    else:
                        print("Error: Failed to merge resource files")
                else:
                    print("Error: Failed to download gitlab resource file")
            else:
                print("Error: Failed to download branch resource file")
        else:
            print("Error: Failed to download main resource file")
    else:
        print("Error: Resources specified for merge don't exist")

# Call this function to lock an unlocked resource in Transifex to prevent translations from being saved
def run_lock(resource, update_time = 0, is_stores = False, updated_comments = False):
    is_change_logs = resource == 'Changelogs'
    if is_stores or does_resource_exist(resource):
        print("Preparing to lock resource")
        if not is_stores:
            resource = PROJECT_ID + ":r:" + resource.lower()
        if updated_comments:
            # This data is fetched in a different way as time changes can't be detected when updating dev comments
            response = {
                "data": []
            }
        else:
            response = do_request(BASE_URL + "/resource_strings?filter[resource]=" + resource)
        if "errors" in response:
            print_error(response["errors"])
            print("Error: Unable to retrieve strings to lock")
            return False
        to_lock = {}
        instructions = {}
        global jira_id
        languages = get_languages()
        locked_tags = ["do_not_translate"]
        if is_change_logs:
            locked_tags.append('change_log')
        for language in languages:
            locked_tags.append("locked_" + languages[language]["code"])
        for string in response["data"]:
            mod_time = datetime.datetime.strptime(string["attributes"]["strings_datetime_modified"], "%Y-%m-%dT%H:%M:%SZ")
            if int(mod_time.replace(tzinfo=datetime.timezone.utc).timestamp()) >= update_time:
                string_tags = string["attributes"]["tags"]
                not_fully_locked = False
                for tag in locked_tags:
                    if tag not in string_tags:
                        not_fully_locked = True
                        string_tags.append(tag)
                if not_fully_locked:
                    to_lock[string["id"]] = string_tags
                    instructions[string["id"]] = jira_id + " " + (string["attributes"]["instructions"] if string["attributes"]["instructions"] else "")
        if to_lock:
            print("Locking strings")
            update_string_meta(to_lock, instructions)
            print("Strings locked successfully")
        elif not updated_comments:
            print("Error: Resource is already locked or there are no strings to lock")
        if updated_comments: 
            print("Locking strings with updated developer comments.")
            to_lock = {}
            for id in updated_comments.keys():
                not_fully_locked = False
                string_tags = updated_comments[id]
                for tag in locked_tags:
                    if tag not in updated_comments[id]:
                        not_fully_locked = True
                        string_tags.append(tag)
                if not_fully_locked:
                    to_lock[id] = string_tags
            update_string_meta(to_lock, instructions)
            update_comments(to_lock)
    else:
        print("Error: Resource " + resource + " not found")

# Call this function to unlock a locked, non-reserved resource in Transifex to allow translations to be saved
def run_unlock(resource):
    if does_resource_exist(resource):
        print("Preparing to unlock strings")
        resource = PROJECT_ID + ":r:" + resource.lower()
        response = do_request(BASE_URL + "/resource_strings?filter[resource]=" + resource)
        if "errors" in response:
            print_error(response["errors"])
            print("Error: Unable to retrieve strings to lock")
            return False
        to_unlock = {}
        languages = get_languages()
        locked_tags = ["do_not_translate"]
        for language in languages:
            locked_tags.append("locked_" + languages[language]["code"])
        for string in response["data"]:
            tmp = []
            unlock = False
            has_no_translate = False
            for tag in string["attributes"]["tags"]:
                if tag == "notranslate":
                    has_no_translate = True
                    tmp.append(tag)
                    unlock = True
                elif tag in locked_tags:
                    unlock = True
                else:
                    tmp.append(tag)
            if unlock:
                if has_no_translate:
                    tmp.append("do_not_translate")
                to_unlock[string["id"]] = tmp
        if to_unlock:
            print("Unlocking strings")
            update_string_meta(to_unlock, {})
            print("Strings unlocked successfully")
        else:
            print("Error: Resource is already unlocked or there are no strings")
    else:
        print("Error: Resource " + resource + " not found")

# Call this function to update the resource with new comments
def run_comment(resource):
    if "Plurals" in resource:
        print("Error: This is not supported for stringsdict resources")
        return False
    resource_key = does_resource_exist(resource)
    if resource_key:
        print("Downloading " + resource)
        resource_content = resource_get_english(resource)
        if resource_content:
            resource_map = content_to_map(resource_content, False)
            edit_string_nodes = []
            create_string_nodes = []
            more_input = True
            comment_keys = []
            while more_input:
                key = input("Enter a string key to edit or press enter to continue: ")
                if key == "":
                    more_input = False
                elif key in resource_map:
                    if resource_map[key]["c"] == None:
                        create_string_nodes.append(key)
                    else:
                        edit_string_nodes.append(key)
                    comment_keys.append(key)
                else:
                    print("Invalid string key entered. Try again")
            if len(create_string_nodes) + len(edit_string_nodes) == 0:
                print("No strings were found to edit")
            else:
                if len(create_string_nodes):
                    print("The following strings did not have a developer comment. Please add one now")
                    for key in create_string_nodes:
                        comment_value = ""
                        while comment_value == "":
                            comment_value = input("Comment for " + key + ": ")
                        resource_map[key]["c"] = comment_value
                if len(edit_string_nodes):
                    print("Please enter the updated developer comment for the following strings")
                    for key in edit_string_nodes:
                        comment_value = ""
                        while comment_value == "":
                            comment_value = input("Comment for " + key + ": ")
                        resource_map[key]["c"] = comment_value
                now = int(datetime.datetime.now(datetime.timezone.utc).timestamp()) - 30
                update_content = process_as_upload(map_to_content(resource_map), False) # Prepare the upload version
                print("Updating Transifex")
                if resource_put_english(resource_key, update_content):
                    comment_ids = {}
                    for key in comment_keys:
                        response = do_request(BASE_URL + '/resource_strings?filter[resource]=' + resource_key + '&filter[key]=' + key)
                        if "errors" in response:
                            print_error(response["errors"])
                        else:
                            for string in response["data"]:
                                if string["attributes"]["key"] == key:
                                    comment_ids[string["id"]] = string["attributes"]["tags"]
                    run_lock(resource, now, False, comment_ids)
                    print("Comments updated in Transifex")
                else:
                    print("Error: Unable to upload updated comments to Transifex")
        else:
            print("Error: Failed to download resource file")
    else:
        print("Error: Unable to find the resource")

# Call this function to initiate pruning for all the available resources for the specified product by the Transifex bot.
def run_pruning(product = False):
    global transifex_bot_token
    global transifex_bot_url
    if transifex_bot_token and transifex_bot_url:
        header = {
            "Authorization": "Bearer " + transifex_bot_token
        }
        i = 30
        url = transifex_bot_url + "?o=prune&pid=ios"
        if product:
            url = url + "@" + str(product)
        while i > 0:
            request = Request(url, headers=header)
            try:
                response = urlopen(request)
            except HTTPError as ex:
                content = ex.read().decode('utf8')
                print('Error: ' + content)
                return False
            content = response.read().decode('utf8')
            if content == '':
                print('Empty response from the Transifex bot')
                return False
            else:
                try:
                    content = json.loads(content)
                    if 'ok' in content:
                        if content['ok']:
                            if 'status' in content and content['status'] == 'pending':
                                if i % 5 == 0:
                                    print('Processing.....')
                                time.sleep(10)
                            i = i - 1
                        elif 'error' in content:
                            print('Error: ' + content['error'])
                            return False
                        else:
                            print('Unknown error')
                            return False
                    elif len(content.keys()) > 0:
                        all_passed = True
                        for key in content.keys():
                            if "ok" in content[key]:
                                if content[key]["pruned"] > 0:
                                    print("Removed " + str(content[key]["pruned"]) + " unused strings from " + key)
                                    print("Backup located in server directory " + content[key]["backup"])
                                else:
                                    print("Nothing to remove from " + key)
                            elif "error" in content[key]:
                                print("Error while processing " + key + ": " + content[key]["error"])
                                all_passed = False
                            else:
                                print("Unknown error when pruning strings")
                                all_passed = False
                        return all_passed
                    else:
                        print('Error: Unexpected result')
                        return False
                except:
                    print('Error: ' + str(content))
                    return False
        print('Error: Pruning timed out')
    else:
        print('Invalid environment variables')

# Call this function to perform a request to Transifex
def do_request(url, json_payload = None, type = "GET"):
    is_git_request = "code.developers.mega.co.nz" in url
    if is_git_request:
        global gitlab_token
        headers = {
            "PRIVATE-TOKEN":  gitlab_token
        }
    else:
        headers = HEADER
    if json_payload == None:
        request = Request(url, headers=headers)
    else:
        request = Request(url, headers=headers, data=json.dumps(json_payload).encode('utf8'))
        if type == "GET":
            type = "POST"
    request.get_method = lambda: type
    try:
        response = urlopen(request)
    except HTTPError as e:
        if is_git_request:
            if e.code == 401:
                print("Error: Invalid Gitlab token")
                return False
            elif e.code == 404:
                print("Error: Unable to find file in Gitlab")
                return False
            else:
                print("Error: Unknown error from Gitlab")
                return False
        elif e.code == 303:
            raise e
        elif e.code == 204:
            return "No Content"
        else:
            errContent = json.loads(e.read().decode('utf-8'))
            errMsg = "Error: Requesting " + url + " failed"
            if json_payload != None:
                errMsg = errMsg + " with payload " + json.dumps(json_payload)
            print(errMsg)
            return errContent
    res = response.read()
    if res == "":
        return {"code": res.code}
    if is_git_request:
        return res
    return json.loads(res)

# Call this function to get all resources in Transifex
def get_resources():
    global resources
    if resources:
        return resources
    response = do_request(BASE_URL + "/resources?filter[project]=" + PROJECT_ID)
    if "errors" in response:
        print("Error: Failed to fetch resource data")
        print_error(response["errors"])
        return resources
    for data in response["data"]:
        resources[data["id"]] = {
            "name": data["attributes"]["name"],
            "strings": data["attributes"]["string_count"]
        }
    return resources

# Call this function to check if resource_name exists in Transifex
def does_resource_exist(resource_name, refresh = False):
    global resources
    if refresh:
        resources = {}
    if len(resources) == 0:
        resources = get_resources()
    for key in resources:
        if resources[key]["name"] == resource_name:
            return key
    return False

# Call this function to get the strings data from the resource
def get_strings_data(resource, is_branch):
    url = BASE_URL + "/resource_strings?filter[resource]=" + PROJECT_ID + ":r:" + resource.lower()
    while url != None:
        response = do_request(url)
        url = None
        if "errors" in response:
            print_error(response["errors"])
            return False
        for string in response["data"]:
            if is_branch:
                branch_strings[string["attributes"]["string_hash"]] = {
                    "tags": string["attributes"]["tags"],
                    "updater": string["relationships"]["committer"]["data"]["id"],
                    "pluralised": string["attributes"]["pluralized"],
                    "id": string["id"],
                }
            else:
                base_strings.append(string["attributes"]["string_hash"])
        if "next" in response["links"] and response["links"]["next"] != None:
            url = response["links"]["next"]
    return True

# Call this function to get the available languages for the project
def get_languages():
    global language_cache
    if language_cache:
        return language_cache
    response = do_request(BASE_URL + "/projects/" + PROJECT_ID + "/languages")
    if "errors" in response:
        print("Error: Failed to retrieve languages")
        print_error(response["errors"])
        return language_cache
    for data in response["data"]:
        language_cache[data["id"]] = {
            "code": data["attributes"]["code"],
            "name": data["attributes"]["name"]
        }
    return language_cache

# Call this function to return the username for the given id or the id if not found
def get_username_from_id(id):
    global user_cache
    if id in user_cache:
        return user_cache[id]
    response = do_request(BASE_URL + "/users/" + id)
    if "errors" in response:
        return id
    if response["data"] and response["data"]["attributes"]["username"]:
        user_cache[id] = response["data"]["attributes"]["username"]
        return user_cache[id]
    return id

# Call this function to get the English file for the given resource
def resource_get_english(resource, is_plurals = False):
    payload = {
        "data": {
            "attributes": {
                "content_encoding": "text",
                "file_type": "default"
            },
            "relationships": {
                "resource": {
                    "data": {
                        "id": PROJECT_ID + ":r:" + resource.lower(),
                        "type": "resources",
                    },
                }
            },
            "type": "resource_strings_async_downloads",
        },
    }
    if resource in [STORES_IOS_ID, STORES_IOS_VPN_ID, STORES_IOS_PWD_ID]:
        payload["data"]["relationships"]["resource"]["data"]["id"] = resource
    if is_plurals:
        content = file_download(payload)
    else:
        content = file_download(payload, "utf-16")
    if content == False:
        print("Error: Unable to download English resource file for " + resource)
        return False
    return content

# Call this function to get the specified languages file for the given resource
def resource_get_language(resource, lang, is_plurals = False):
    payload = {
        "data": {
            "attributes": {
                "content_encoding": "text",
                "file_type": "default",
                "mode": "sourceastranslation"
            },
             "relationships": {
                "language": {
                    "data": {
                        "id": lang,
                        "type": "languages"
                    }
                },
                "resource": {
                    "data": {
                        "id": PROJECT_ID + ":r:" + resource.lower(),
                        "type": "resources",
                    },
                }
            },
            "type": "resource_translations_async_downloads"
        }
    }
    if is_plurals:
        content = file_download(payload)
    else:
        content = file_download(payload, "utf-16")
    if content == False:
        print("Error: Unable to download English resource file for " + resource)
        return False
    return content

# Call this function to upload a base resource file to Transifex
def resource_put_english(resource, content, force = False):
    payload = {
        "data": {
            "attributes": {
                "content": content,
                "content_encoding": "text",
                "replace_edited_strings": force,
            },
            "relationships": {
                "resource": {
                    "data": {
                        "id": resource.lower(),
                        "type": "resources",
                    },
                },
            },
            "type": "resource_strings_async_uploads",
        },
    }
    return file_upload(payload)

# Call this function to download the gitlab strings file for the resource
def gitlab_download(resource, language = "Base"):
    if "LTHPasscodeViewController" in resource:
        return False
    global config_map
    url = GITLAB_URL.replace("$file", get_file_basename(resource)).replace("$path", config_map[resource].replace("/", "%2F"))
    if language != "Base":
        if language in REMAPPED_CODE:
            language = REMAPPED_CODE[language]
        url = url.replace("Base.lproj", language + ".lproj")
    content = do_request(url)
    if content:
        return content.decode("utf-8")
    return False

# Call this function to download a file defined by the payload
def file_download(payload, encoding = "utf-8"):
    url = BASE_URL + "/" + payload["data"]["type"]
    response = do_request(url, payload)
    if "errors" in response:
        print_error(response["errors"])
        return False
    wait_url = response["data"]["links"]["self"]
    data = await_download(wait_url, encoding)
    if data == False:
        return False
    return data

# Call this function to upload a resource/translation file to Transifex
def file_upload(payload):
    url = BASE_URL + "/" + payload["data"]["type"]
    response = do_request(url, payload)
    if "errors" in response:
        print_error(response["errors"])
        return False
    wait_url = response["data"]["links"]["self"]
    return await_upload(wait_url)

# Call this function to await a file download request
def await_download(url, encoding = "utf-8"):
    class NoRedirect(HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, headers, newurl):
            return None
    opener = build_opener(NoRedirect)
    install_opener(opener)
    for i in range(50):
        try:
            response = do_request(url)
            if "errors" in response:
                print_error(response["errors"])
                return False
            if response["data"]["attributes"]["status"] == "failed":
                if response["data"]["attributes"]["errors"]:
                    print_error(response["data"]["attributes"]["errors"])
                return False
        except HTTPError as e:
            if e.code == 303:
                file = urlopen(e.headers["Location"])
                response = file.read().decode(encoding)
                return response
            elif e.code != 200:
                response = json.loads(e.read().decode("utf-8"))
                if "errors" in response:
                    print_error(response["errors"])
                return False
        time.sleep(2)
    return False

# Call this function to await a file upload request
def await_upload(url):
    for i in range(50):
        response = do_request(url)
        if "errors" in response:
            print_error(response["errors"])
            return False
        elif response["data"]["attributes"]["status"] == "failed":
            if response["data"]["attributes"]["errors"]:
                print_error(response["data"]["attributes"]["errors"])
            return False
        elif response["data"]["attributes"]["status"] != "pending":
            return True
        time.sleep(2)
    return False

# Call this function to convert the file into the upload formatted version for Transifex
def process_as_download(file_content, is_plurals):
    return map_to_content(content_to_map(file_content, False, is_plurals), is_plurals)

# Call this function to convert the file downloaded from Transifex into the correct formatted version
def process_as_upload(file_content, is_plurals):
    return map_to_content(content_to_map(file_content, True, is_plurals), is_plurals)

# Call this function to update the string tags for a resource.
def update_string_meta(to_lock, string_instructions):
    for key in to_lock:
        payload = {
            "data": {
                "attributes": {
                    "tags": to_lock[key]
                },
                "id": key,
                "type": "resource_strings"
            }
        }
        if key in string_instructions and string_instructions[key]:
            payload["data"]["attributes"]["instructions"] = string_instructions[key].strip()
        response = do_request(BASE_URL + "/resource_strings/" + key, payload, "PATCH")
        if "errors" in response:
            print_error(response["errors"])

# Call this function to create a string comment after the strings developer comments have been updated
def update_comments(to_comment):
    for key in to_comment:
        payload  = {
            "data": {
                "attributes": {
                    "message": "The developer comment has been updated. Please check the new comment and update as needed.",
                    "type": "comment",
                },
                "relationships": {
                    "language": {
                        "data": {
                            "id": "l:en",
                            "type": "languages"
                        }
                    },
                    "resource_string": {
                        "data": {
                            "id": key,
                            "type": "resource_strings"
                        }
                    }
                },
                "type": "resource_string_comments"
            }
        }
        response = do_request(BASE_URL + "/resource_string_comments", payload)
        if "errors" in response:
            print_error(response["errors"])

# Call this function to merge resource_content and branch_content into one file
def merge_strings(resource_content, branch_content, upload, is_plurals, merge_different_langs = False):
    full_map = content_to_map(resource_content, upload, is_plurals)
    part_map = content_to_map(branch_content, upload, is_plurals)
    for key in part_map:
        if merge_different_langs:
            if is_plurals or len(part_map[key]["s"].strip()) > 0:
                full_map[key] = part_map[key]
        else:
            full_map[key] = part_map[key]
    return map_to_content(full_map, is_plurals)

# Call this function to check if a string mapping is equivalent to another
def strings_equal(string_a, string_b, is_plurals = False):
    if is_plurals:
        if string_a["ctx"] != string_b["ctx"]:
            return False
        if string_a["var"] != string_b["var"]:
            return False
        for key in string_a["str"]:
            if string_a["str"][key] != string_b["str"][key]:
                return False
    else:
        if string_a["c"] != string_b["c"]:
            return False
        if string_a["s"] != string_b["s"]:
            return False
    return True

# Call this function to return the children of the parent as pure XML
def subnodes_as_text(parent):
    node_value = ""
    for node in parent.childNodes:
        node_value = node_value + node.toxml()
    return node_value

# Call this function to convert a plist xml node to a plural string mapping
def get_plural_data(node, upload):
    map = {
        "var": subnodes_as_text(node.getElementsByTagName('string')[0]),
        "ctx": subnodes_as_text(node.getElementsByTagName('key')[1]),
        "str": {}
    }
    i = 0
    key = ""
    skip = 2
    data_dict = node.getElementsByTagName('dict')[0]
    while i < len(data_dict.childNodes):
        child = data_dict.childNodes[i]
        if child.nodeType == child.ELEMENT_NODE:
            if skip > 0:
                skip -= 1
            else:
                if child.tagName == "key":
                    key = subnodes_as_text(child)
                elif child.tagName == "string":
                    map["str"][key] = replace_characters(subnodes_as_text(child), upload)
        i += 1
    return map

# Call this function to convert a strings file to a strings mapping
def content_to_map(file_content, upload, is_plurals = False):
    map = {}
    if is_plurals:
        doc = parseString(file_content)
        root_dict = doc.getElementsByTagName('dict')[0]
        string_key = ""
        for node in root_dict.childNodes:
            if node.nodeType == node.ELEMENT_NODE:
                if node.tagName == "key":
                    string_key = subnodes_as_text(node)
                elif node.tagName == "dict":
                    map[string_key] = get_plural_data(node, upload)
    else:
        global unicode_regex
        file_content = re.sub(unicode_regex, '', file_content)
        lines = file_content.split("\n")
        i = 0
        context = ""
        while i < len(lines):
            lines[i] = lines[i].strip()
            if "/*" == lines[i][0:2] and "*/" == lines[i][-2:len(lines[i])]:
                context = lines[i][2:-2].strip()
            elif len(lines[i]) >= 6 and lines[i][0] == "\"" and lines[i][-1] == ";":
                parts = lines[i].split("=", 1)
                map[parts[0].strip()[1:-1]] = {
                    'c': context,
                    's': replace_characters(parts[1].strip()[1:-2], upload)
                }
            i += 1
    return map

# Call this function to convert a strings mapping to a strings file
def map_to_content(map, is_plurals = False):
    file = ""
    if is_plurals:
        file = []
        file.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
        file.append("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">")
        file.append("<plist version=\"1.0\">")
        file.append("<dict>")
        for key in map:
            file.append(tagify("key", key))
            file.append("<dict>")
            file.append(tagify("key", "NSStringLocalizedFormatKey"))
            file.append(tagify("string", map[key]["var"]))
            file.append(tagify("key", map[key]["ctx"]))
            file.append("<dict>")
            file.append(tagify("key", "NSStringFormatSpecTypeKey"))
            file.append(tagify("string", "NSStringPluralRuleType"))
            for sub_key in map[key]["str"]:
                file.append(tagify("key", sub_key))
                file.append(tagify("string", map[key]["str"][sub_key]))
            file.append("</dict>")
            file.append("</dict>")
        file.append("</dict>")
        file.append("</plist>")
        return indent_xml(file)
    else:
        for key in map:
            file += "/* " + map[key]["c"] + " */\n"
            file += "\"" + key + "\"=\"" + map[key]["s"] + "\";\n"
    return file.strip()

# Call this function to return a string of the given xml tag with the value
def tagify(tag, value):
    return "<" + tag + ">" + value + "</" + tag + ">"

# Call this function to check if the upload content is valid
def validate_file(file_content, is_plurals = False):
    valid = True
    if is_plurals:
        try:
            parseString(file_content)
        except ExpatError as ex:
            print("Error: Failed to parse stringsdict file: " + str(ex))
            valid = False
        return valid
    global unicode_regex
    file_content = re.sub(unicode_regex, '', file_content)
    lines = file_content.split("\n")
    i = 0
    while i < len(lines):
        lines[i] = lines[i].strip()
        if "/*" == lines[i][0:2] and "*/" == lines[i][-2:len(lines[i])]:
            i = i # No-op. Valid comment
        elif len(lines[i]) >= 6 and lines[i][0] == "\"" and lines[i][-1] == ";":
            parts = lines[i].split("=", 1)
            key = parts[0].strip()[1:-1]
            string = parts[1].strip()[1:-2]
            if len(key) > 0 and len(string) > 0:
                key_matches = re.search('(?<!\\\\)(?:\\\\{2})*"', key)
                string_matches = re.search('(?<!\\\\)(?:\\\\{2})*"', string)
                if key_matches != None or string_matches != None:
                    print("Error: Invalid quote escapes on line " + str(i + 1))
                    valid = False
            else:
                print("Error: Invalid string line for line " + str(i + 1))
                valid = False
        else:
            print("Error: Invalid comment or string entry on line " + str(i + 1))
            valid = False
        i += 1
    return valid

# Call this function to replace characters in a node/string with the correct version
def replace_characters(string, upload):
    replace = [
        r"'''",                                                # A. Triple prime
        r'(\W|^)"(\w)',                                        # B. Beginning double quote
        r'(“[^"]*)"([^"]*$|[^“"]*“)',                          # C. Ending double quote
        r'([^0-9])"',                                          # D. Remaining double quote at the end of word
        r"''",                                                 # E. Double prime as two single quotes
        r"(\W|^)'(\S)",                                        # F. Beginning single quote
        r"([A-z0-9])'([A-z])",                                 # G. Conjunction's possession
        r"(‘)([0-9]{2}[^’]*)(‘([^0-9]|$)|$|’[A-z])",           # H. Abbreviated years like '93
        r"((‘[^']*)|[A-z])'([^0-9]|$)",                        # I. Ending single quote
        r"(\B|^)‘(?=([^‘’]*’\b)*([^‘’]*\B\W[‘’]\b|[^‘’]*$))",  # J. Backwards apostrophe
        r'"',                                                  # K. Double prime
        r"'",                                                  # L. Prime
        r"\.\.\."                                              # M. Ellipsis
    ]
    replace_to = [
        r'‴',        # A
        r'\1“\2',    # B
        r'\1”\2',    # C
        r'\1”',      # D
        r'″',        # E
        r"\1‘\2",    # F
        r"\1’\2",    # G
        r"’\2\3",    # H
        r"\1’\3",    # I
        r"\1’",      # J
        r"″",        # K
        r"′",        # L
        r"…"         # M
    ]
    global xml_tag_regex
    tags = xml_tag_regex.findall(string)
    for i in range(len(tags)):
        string = string.replace(tags[i], " <t " + str(i) + "> ")
    if upload:
        string = string.replace("\r\n", "[Br]")
        string = string.replace("\r", "[Br]")
        string = string.replace("\n", "[Br]")
        string = string.replace(r"\r\n", "[Br]")
        string = string.replace(r"\r", "[Br]")
        string = string.replace(r"\n", "[Br]")
        string = string.replace("\\", "")
        for i in range(len(replace)):
            string = re.sub(replace[i], replace_to[i], string)
    else:
        string = re.sub(replace[12], replace_to[12], string)
        string = string.replace("[x]", "[X]")
        string = string.replace("[a]", "[A]")
        string = string.replace("[/a]", "[/A]")
        string = string.replace("[b]", "[B]")
        string = string.replace("[/b]", "[/B]")
        string = string.replace("[a1]", "[A1]")
        string = string.replace("[/a1]", "[/A2]")
        string = string.replace("[a2]", "[A2]")
        string = string.replace("[/a2]", "[/A2]")
        string = string.replace("[x1]", "[X1]")
        string = string.replace("[/x1]", "[/X1]")
        string = string.replace("[x2]", "[X2]")
        string = string.replace("[/x2]", "[/X2]")
        string = string.replace("\n", "")
        string = string.replace("\r", "")
        string = string.replace("[Br]", r"\n")

    for i in range(len(tags)):
        string = string.replace(" <t " + str(i) + "> ", tags[i])
    return string

# Call this function to correctly indent an XML string array with 2 spaces per indent
def indent_xml(lines):
    result = ""
    padding = 0
    for i in range(len(lines)):
        token = lines[i].lstrip()
        matches = re.search(r'.+<\/\w[^>]*>$', token)
        if matches == None:
            matches = re.search(r'^<\/\w', token)
            if matches == None:
                matches = re.search(r'^<\w[^>]*[^\/]>.*$', token)
                if matches == None:
                    indent = 0
                else:
                    indent = 2
            else:
                padding -= 2
                indent = 0
        else:
            indent = 0
        line = token.rjust(len(token) + padding, ' ')
        result = result + line + "\n"
        padding += indent
    return result.strip()

# Call this function to store a resource file in the correct directory
def store_file(resource, content, lang = "Base"):
    if lang in REMAPPED_CODE:
        lang = REMAPPED_CODE[lang]
    if resource in RESERVED_RESOURCES:
        file_path = get_reserved_resource_path(resource) + lang + ".lproj/" + get_file_basename(resource)
    elif "Changelogs" in resource:
        file_path = DOWNLOAD_FOLDER + "Changelogs.strings-" + lang
    else:
        file_path = PROD_FOLDER + lang + ".lproj/" + get_file_basename(resource)
    print("Saving file " + file_path)
    file_put_contents(file_path, content)
    if lang == "Base" and ("Localizable" in resource or "InfoPlist" in resource or "Plurals" in resource):
        file_put_contents(file_path.replace("Base", "en"), content)

# Wrapper to write content to file
def file_put_contents(filepath, content):
    with open(filepath, "w") as file:
        return file.write(content) > 0

# Call this function to return a resource name based on the current git branch
def get_branch_name():
    global git_path
    cur_path = os.getcwd()
    os.chdir(git_path)
    branch_name = subprocess.check_output(['git', 'symbolic-ref', '--short', '-q', 'HEAD'], universal_newlines=True).strip()
    os.chdir(cur_path)
    if branch_name in ["master", "develop", "main"]:
        return False
    return re.sub('[^A-Za-z0-9]+', '', branch_name)

# Call this function to return the general file name for the given resource
def get_file_basename(resource):
    if "-" in resource:
        if "Plurals" in resource:
            return resource.replace("Plurals", "Localizable") + ".stringsdict"
        else:
            return resource + ".strings"
    else:
        if "Plurals" in resource:
            return "Localizable.stringsdict"
        elif "Localizable" in resource:
            return "Localizable.strings"
        elif "InfoPlist" in resource:
            return "InfoPlist.strings"
        else: 
            print("WARN: Unexpected resource name. Cannot retrieve base file name for " + resource)
            print("Defaulting to Localizable.strings")
            return "Localizable.strings"

# Call this function to log errors from the Transifex API
def print_error(errors):
    for error in errors:
        code = "(missing error code)"
        if "status" in error:
            code = error["status"]
        elif "code" in error:
            code = error["code"]
        print("Error: {}: {}.".format(code, error["detail"]))

# Call this function to download the content for the stores resource
def run_download_stores(resource = "ios"):
    print("Downloading stores resource")
    file_name = DOWNLOAD_FOLDER + "/stores-" + resource.replace("stores", "") + ".yaml"
    if "vpn" in resource:
        resource = STORES_IOS_VPN_ID
    elif "password" in resource:
        resource = STORES_IOS_PWD_ID
    # elif "abc" in resource:
    #   resource = STORES_ABC_ID
    else:
        resource = STORES_IOS_ID
    content = resource_get_english(resource, True) # Not a plurals resource but is not UTF-16 encoded
    if content:
        file_put_contents(file_name, content)
    else:
        print("Error: Failed to retrieve stores strings")
    return False

# Call this function to upload the content for a stores resource
def run_upload_stores(content, resource = "ios"):
    if content:
        now = int(datetime.datetime.now(datetime.timezone.utc).timestamp()) - 30
        if "vpn" in resource:
            resource = STORES_IOS_VPN_ID
        elif "password" in resource:
            resource = STORES_IOS_PWD_ID
        # elif "abc" in resource:
        #   resource = STORES_ABC_ID
        else:
            resource = STORES_IOS_ID
        print("Uploading to stores resource")
        # Force update all the strings including those with edited content.
        if resource_put_english(resource, content, True):
            return run_lock(resource, now, True)
        else:
            print("Error: Failed to update the iOS stores resource file")
        return False
    else:
        print("Error: No file content present")
        return False
    
# Return the path to store the strings files for the given RESERVED_RESOURCES resource.
def get_reserved_resource_path(resource):
    global config_map
    global git_path

    if resource not in config_map:
        print("ERROR: Resource not configured in resources.conf: " + resource)
        sys.exit(1)
    
    return git_path + "/" + config_map[resource]

# Return if the content has developer comments on all strings present.
def missing_developer_comments(content_map, is_plurals = False):
    result = False
    if is_plurals:
        return result
    
    for key in content_map:
        if "c" not in content_map[key] or content_map[key]["c"].strip() == "":
            print("Invalid developer comment found for string key: " + key)
            result = True
    return result

# Parses arguments and runs relevant mode
def main():
    print("--- Transifex Language Management ---")
    parser = argparse.ArgumentParser()
    parser.add_argument("-m", "--mode", nargs=1, help="The mode of the script to run", type=str)
    parser.add_argument("-d", "--download", nargs="?", help="Downloads the given resource as a file", const=True, default=False)
    parser.add_argument("-u", "--upload", nargs="?", help="Uploads the given file", const=True, default=False)
    parser.add_argument("-r", "--resource", nargs=1, help="The Transifex resource to perform the action for")
    parser.add_argument("-b", "--branch", nargs="?", help="The Transifex branch resource to perform the action for", const=True, default=False)
    parser.add_argument("-f", "--file", nargs=1, help="The file to process or output to")
    parser.add_argument("-j", "--jira", nargs=1, help="The JIRA ticket id for the current branch e.g: IOS-1234")
    parser.add_argument("-s", "--startPath", nargs=1, help="The start path in the repository where the strings files will be stored. e.g: /feature/")
    parser.add_argument("-l", "--library", nargs=1, help="The specific library to interact with. Only should be used in the library project. e.g: -l auth = Localizable_auth_lib")
    args = parser.parse_args()

    global PROD_FOLDER
    if args.startPath:
        global git_path
        if not os.path.isdir(git_path + args.startPath[0]):
            print(git_path + args.startPath[0] + " is not a folder. Please ensure you entered the path correctly and the folder exists already")
            sys.exit(1)
        PROD_FOLDER = git_path + args.startPath[0]
    
    if not os.path.isdir(PROD_FOLDER + "Base.lproj"):
        os.makedirs(PROD_FOLDER + "Base.lproj")

    if args.jira:
        global jira_id
        jira_id = args.jira[0]

    global is_lib
    lib_stem = ""
    if args.library and is_lib:
        lib_stem = args.library[0]
    if args.mode:
        mode = args.mode[0].lower()
        if mode == "download":
            resource = "Localizable"
            if lib_stem:
                resource = "Localizable_" + lib_stem + "_lib"
            branch = get_branch_name()
            if args.resource and args.branch:
                resource = args.resource[0]
                branch = args.branch
                run_merge(resource, branch)
            elif args.resource:
                if args.resource[0] == "all":
                    run_fetch()
                elif "stores" in args.resource[0]:
                    run_download_stores(args.resource[0])
                else:
                    run_download(args.resource[0], PROD_FOLDER)
            else:
                if branch:
                    if lib_stem:
                        branch = "Localizable_" + lib_stem + "_lib-" + branch
                    else:
                        branch = "Localizable-" + branch
                    run_merge(resource, branch)
                else:
                    print("Error: Cannot merge resources for develop/master branch")
        elif mode == "upload":
            branch = get_branch_name()
            if not branch and not args.resource:
                print("Error: Cannot update unspecified resource for develop/master branch")
            elif args.resource:
                resource = args.resource[0]
                if "LTHPasscodeViewController" in resource:
                    file_path = git_path + "/iMEGA/Vendor/LTHPasscodeViewController/Localizations/LTHPasscodeViewController.bundle/Base.lproj/" + file_name
                    branch = False
                elif "Changelogs" in resource:
                    file_path = DOWNLOAD_FOLDER + "Changelogs.strings-Base"
                    branch = False
                elif "stores" in resource:
                    print("Checking stores file content")
                else:
                    file_path = get_reserved_resource_path(resource) + "Base.lproj/" + get_file_basename(resource)
                if args.file:
                    file_path = args.file[0]
                if os.path.exists(file_path):
                    content = file_get_contents(file_path)
                    if "stores" in resource:
                        run_upload_stores(content, resource)
                    else:
                        run_upload(content, resource, branch)
                else:
                    print("Error: Can not locate file for the specified resource")
            else:
                print("Error: No resource specified for -r/--resource")
        elif mode == "branch":
            if args.resource:
                run_branch(args.resource[0])
            else:
                if lib_stem:
                    run_branch("Localizable_" + lib_stem + "_lib")
                else:
                    run_branch("Localizable")
        elif mode == "feature":
            if args.resource:
                run_branch(args.resource[0], True)
            else:
                print("Error: No name specified for feature resource")
        elif mode == "lock":
            if args.resource:
                if args.resource[0] in RESERVED_RESOURCES:
                    print("Error: Cannot lock a reserved resource")
                else:
                    run_lock(args.resource[0])
            else:
                print("Error: No resource specified")
        elif mode == "unlock":
            if args.resource:
                run_unlock(args.resource[0])
            else:
                print("Error: No resource specified")
        elif mode == "list":
            resources = get_resources()
            for resource in resources:
                data = ""
                if resources[resource]["name"] in RESERVED_RESOURCES:
                    data = "Reserved resource. "
                data = data + "Name: " + resources[resource]["name"] + ". ID: " + resource + ". String count: " + str(resources[resource]["strings"])
                print(data)
        elif mode == "fetch":
            run_fetch()
        elif mode == "export":
            run_export(args.branch)
        elif mode == "lang":
            resource = "Localizable"
            if args.resource:
                resource = args.resource[0]
            run_export(True, resource)
        elif mode == "comment":
            if args.resource:
                run_comment(args.resource[0])
            else:
                print("Error: No resource specified")
        elif mode == "clean":
            if args.resource:
                run_pruning(args.resource[0])
            else:
                run_pruning()
    elif args.download:
        resource = "Localizable"
        if lib_stem:
            resource = "Localizable_" + lib_stem + "_lib"
        branch = get_branch_name()
        if args.resource and args.branch:
            resource = args.resource[0]
            branch = args.branch
            run_merge(resource, branch)
        elif args.resource:
            if args.resource[0] == "all":
                run_fetch()
            elif "stores" in args.resource[0]:
                run_download_stores(args.resource[0])
            else:
                run_download(args.resource[0], PROD_FOLDER)
        else:
            if branch:
                if lib_stem:
                    branch = "Localizable_" + lib_stem + "_lib-" + branch
                else:
                    branch = "Localizable-" + branch
                run_merge(resource, branch)
            else:
                print("Error: Cannot merge resources for develop/master branch")
    elif args.upload:
        branch = get_branch_name()
        if not branch and not args.resource:
            print("Error: Cannot update unspecified resource for develop/master branch")
        elif args.resource:
            resource = args.resource[0]
            if "LTHPasscodeViewController" in resource:
                file_path = git_path + "/iMEGA/Vendor/LTHPasscodeViewController/Localizations/LTHPasscodeViewController.bundle/Base.lproj/" + file_name
                branch = False
            elif "Changelogs" in resource:
                file_path = DOWNLOAD_FOLDER + "Changelogs.strings-Base"
                branch = False
            elif "stores" in resource:
                print("Checking stores file content")
            else:
                file_path = get_reserved_resource_path(resource) + "Base.lproj/" + get_file_basename(resource)
            if args.file:
                file_path = args.file[0]
            if os.path.exists(file_path):
                content = file_get_contents(file_path)
                if "stores" in resource:
                    run_upload_stores(content, resource)
                else:
                    run_upload(content, resource, branch)
            else:
                print("Error: Can not locate file for the specified resource")
        else:
            print("Error: No resource specified for -r/--resource")
    else:
        print("Error: Invalid script mode.")
    sys.exit(0)

try:
    main()
except KeyboardInterrupt:
    sys.exit(1)
