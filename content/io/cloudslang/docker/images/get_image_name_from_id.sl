#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Retrieves the image name of the specified id.
#
# Inputs:
#   - docker_options - optional - options for the docker environment - from the construct: docker [OPTIONS] COMMAND [arg...]
#   - host - Docker machine host
#   - port - optional - SSH port - Default: 22
#   - username - Docker machine username
#   - password - optional - Docker machine password
#   - image_id - Docker image ID
#   - privateKeyFile - optional - absolute path to private key file - Default: none, required: false
#   - arguments - optional - arguments to pass to the command - Default: none, required: false
#   - characterSet - optional - character encoding used for input stream encoding from target machine - Valid: SJIS, EUC-JP, UTF-8 - Default: UTF-8, required: false
#   - pty - optional - whether to use PTY - Valid: true, false - Default: false
#   - timeout - time in milliseconds to wait for command to complete - Default: 30000000
#   - closeSession - optional - if false SSH session will be cached for future calls during the life of the flow, if true the SSH session used will be closed; Valid: true, false - Default: false
# Outputs:
#   - image_list - list containing REPOSITORY and TAG for all the Docker images
# Results:
#   - SUCCESS - SSH command succeeded
#   - FAILURE - SSH command failed
####################################################
namespace: io.cloudslang.docker.images

imports:
  ssh: io.cloudslang.base.remote_command_execution.ssh

flow:
  name: get_image_name_from_id
  inputs:
    - docker_options:
        required: false
    - docker_options_expression:
        default: docker_options + ' ' if bool(docker_options) else ''
        overridable: false
    - host
    - port:
        required: false
    - username
    - password:
        required: false
    - image_id
    - privateKeyFile:
        required: false
    - command:
        default: >
            "docker " + docker_options_expression + "images | grep " + image_id + " | awk '{print $1 \":\" $2}'"
        overridable: false
    - arguments:
        required: false
    - characterSet:
        required: false
    - pty:
        default: "'false'"
    - timeout:
        default: "'30000000'"
    - closeSession:
        default: "'false'"

  workflow:
    - get_image_name_from_id:
        do:
          ssh.ssh_flow:
            - host
            - port:
                required: false
            - username
            - password:
                required: false
            - privateKeyFile:
                required: false
            - command
            - arguments:
                required: false
            - characterSet:
                required: false
            - pty:
                required: false
            - timeout
            - closeSession:
                required: false
            - agentForwarding:
                required: false
        publish:
          - image_name: returnResult.replace("\n"," ").replace("<none>:<none> ","").replace("REPOSITORY:TAG ","")
        navigate:
          SUCCESS: SUCCESS
          FAILURE: FAILURE
          FAIL_VALIDATE_SSH: FAILURE

  outputs:
    - image_name
