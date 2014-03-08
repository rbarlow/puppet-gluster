# GlusterFS module by James
# Copyright (C) 2010-2013+ James Shubin
# Written by James Shubin <james@shubin.ca>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'facter'

groupdir = '/var/lib/glusterd/groups/'

found = {}

if File.directory?(groupdir)
	Dir.glob(groupdir+'*.*').each do |f|
		b = File.basename(f)

		if not found.key?(b)
			found[b] = {}	# initialize
		end

		groups = File.open(f, 'r').read		# read into str
		groups.each_line do |line|
			split = line.split('=')		# split key=value pairs
			if split.length == 2
				key = split[0]
				value = split[1]
				if found[b].key?(key)
					# NOTE: error found in file...
					print "There is a duplicate key in the '#{b}' group."
				end
				found[b][key] = value
			end
		end
	end
end

# list of available property groups
Facter.add('gluster_property_groups') do
	#confine :operatingsystem => %w{CentOS, RedHat, Fedora}
	setcode {
		found.keys.sort.join(',')
	}
end

# each group's list of key value pairs
found.keys.each do |x|
	Facter.add('gluster_property_group_'+x) do
		#confine :operatingsystem => %w{CentOS, RedHat, Fedora}
		setcode {
			# don't reuse single variable to avoid bug #:
			# http://projects.puppetlabs.com/issues/22455
			# TODO: facter should support native hash types :)
			found[x].collect{|k,v| k+'='+v}.join(',')
		}
	end
end

# vim: ts=8
