+++
categories = ["SSB", "Setup"]
date = "2018-08-12"
description = "Secure Scuttlebutt Setup"
slug = "ssb-setup"
tags = ["setup","SSB","scuttlebut"]
title = "SSB Setup"
+++
This will serve as a writeup of how I setup and run zie.one's SSB instance.

2 "types" of machines:

* Gateway VPS: zie.one main domain running OpenBSD-current.
* SSB pub server vps, running Debian 9

There will be at least 1 SSB pub server, possibly more than one, initially I had 2, but the load wasn't there,
so there is only one at the time of this writing, but the system is setup to handle N amount of nodes.
When I turn up another SSB instance, I will make the first SSB node(or maybe the gateway) become an NFS server, 
so all SSB nodes share the same ~/.ssb data dir.

The SSB VPS have internal IP's on the same network as the openBSD gateway. my VPS host covers this for me
at no charge, as long as they are in the same datacenter.

SSB pub server setup:
================

Setup swap:
---------------

	dd if=/dev/zero of=/swapfile bs=1024 count=1204000
	chmod 600 /swapfile
	mkswap /swapfile
	swapon /swapfile

Install node, nvm and supervisor
--------------------------------

	apt install nodejs supervisor
	adduser --system ssb
	sudo -u ssb bash
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
	nvm install --lts
	npm install --global scuttlebot
	see:
		https://ssbc.github.io/docs/scuttlebot/howto-setup-a-pub.html
		and https://ssbc.github.io/docs/scuttlebot/tutorial.html

Setup supervisor to run SSB
----------------------------------
	$ cat /etc/supervisor/conf.d/ssb.conf
	[program:ssb]
	command=/home/ssb/.nvm/versions/node/v8.11.1/bin/node /home/ssb/.nvm/versions/node/v8.11.1/bin/sbot server --host zie.one
	; Setup the environment
	environment=HOME="/home/ssb",USER="ssb"
	directory=/home/ssb
	user=ssb
	autorestart=true

Firewall/relayd configuration
======================

There are variables here that need to be replaced, they are shown here as $(). 
Also, sorry.zie.one should live on some other machine/IP, listen on port 8008 and return something useful, saying all SSB nodes seem to be down, and should also yell and scream at someone(like me) to go fix it.  This has yet to be fully implemented. 

	$ cat /etc/relayd.conf
	ssb1=$(SSB node 1 internal address)
	ssb2=$(SSB node 2 internal address)

	interval 5

	table <ssbhosts> { $ssb1, $ssb2 }
	table <sorryhost> disable { sorry.zie.one }

	protocol "ssb" {
			tcp { socket buffer 65536 }
	}

	relay "ssbforward" {
			listen on $(PUBLICIPV4 ADDRESS) port 8008
			listen on $(PUBLICIPV6ADDRESS) port 8008
			protocol ssb

			forward to <ssbhosts> port 8008 timeout 300 check tcp
			forward to <sorryhost> port 8008 timeout 300 check icmp


Extras
=====

Not covered here: 

* setup prometheus and node_exporter, so we can monitor load, etc across time.
* clean up logs, so we only store the connecting IP's for 24hrs per policy
* configure PF to allow 8008 traffic into relayd, and other server hardening.}
* email setup, log monitoring, etc.

Thoughts and suggestions on making this better are *VERY* welcome.