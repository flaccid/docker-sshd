# docker-sshd

OpenSSH server in a Docker image.

## Usage

### Build

    $ docker build -t sshd .

### Run

Typically:

    $ docker run -itd -p 1337:22 -e SSH_PUBLIC_KEY="ssh-rsa AAAAB3Nza...s1jw== mypubkey" sshd

#### Runtime Environment Variables

There should be a reasonable amount of flexibility using the available variables. If not please raise an issue so your use case can be covered!

- `SSH_PUBLIC_KEY` - The SSH public key to place in `/root/.ssh/authorized_keys` for access tot he server

### Tag and Push

    $ docker tag -f sshd flaccid/sshd
    $ docker push flaccid/sshd

License and Authors
-------------------
- Author: Chris Fordham (<chris@fordham-nagy.id.au>)

```text
Copyright 2016, Chris Fordham

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
