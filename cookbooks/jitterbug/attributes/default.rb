#
# Author:: David A. Golden (<dagolden@cpan.org>)
# Cookbook Name:: jitterbug
# Attribute:: default
#
# Copyright 2012, David A. Golden
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# perlbrew to execute with (should be a legal perlbrew target)
default['jitterbug']['perl_version'] = 'perl-5.14.2'

# Install directory, repo and tag
default['jitterbug']['deploy_dir'] = '/opt/jitterbug'
default['jitterbug']['deploy_repo'] = 'git://github.com/dagolden/jitterbug.git'
default['jitterbug']['deploy_tag'] = 'carton-chef'

# Service user/group/port
default['jitterbug']['user'] = "jitterbug"
default['jitterbug']['group'] = "jitterbug"
default['jitterbug']['port'] = 3000

# Jitterbug config
default['jitterbug']['db_dir'] = "/var/lib/jitterbug"
default['jitterbug']['conf_dir'] = "/etc/jitterbug"
default['jitterbug']['on_failure_subject_prefix'] = "[jitterbug] FAIL "
default['jitterbug']['on_failure_to_email'] = ""
default['jitterbug']['on_failure_cc_email'] = "alice@example.com"
default['jitterbug']['on_failure_from_email'] = "donotreply@example.com"
default['jitterbug']['on_pass_subject_prefix'] = "[jitterbug] PASS "
default['jitterbug']['on_pass_to_email'] = ""
default['jitterbug']['on_pass_cc_email'] = "alice@example.com"
default['jitterbug']['on_pass_from_email'] = "donotreply@example.com"
