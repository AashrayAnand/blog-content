---
author: "Aashray"
include_toc: true
title: "Let's Build a Router Part 2"
date: 2021-11-08T08:40:29-08:00
draft: false
---

***Welcome back! If you followed part 1 of this series, then we’ll be answering a lot of the questions you may have had from last time, and if not, I’d highly suggest reading [part 1](/posts/lets-build-a-router-part-1/) before we continue our journey to building a router.***

To recap, we’ve set up our 3 virtual networks, and we’ve configured a router with one network adapter connected to the switches of each private network, and a 4th network adapter connected to a switch shared with our host machine’ network adapter, thus exposing Internet access to our router. Our network topology looks like below:

![vlan_visual](/vlan_visual3.png)

We ended up with the question, why can’t we connect from our private networks to the Internet? This is unfortunately not a simple fix, but the first part of the answer is that the ethernet protocol which we have built our network configuration on facilitates communication between devices connected to the same ethernet switch, not between switches. 

As it stands, we have 3 switches, comprised of a pair of VMs, and a router, and within these groups of 3, we can now communicate, where each ethernet interface is assigned a MAC address, to which traffic is routed from other hosts. To take the next step inter-networking between our private networks, and with the Internet, we’ll need to use IP.

### What is IP

The Internet Protocol, known as IP, is a software layer which builds on top of L2 networking, implementing several key capabilities on top of what L2 networking provides. The defining achievement of IP is what is typically referred to as packet switching, which is the process of routing discrete chunks of data, known as packets, from a source machine to its destination, spanning multiple L2 networks, allowing machines not physically connected to the same network to be able to communicate with each other.

Let’s solidify this with a home network example. Whenever we try to access a website on the Internet from one of our devices, we require a connection for transmitting packets between our device, and the destination machine, or server, which serves this website. This server may be anywhere in the world, and almost certainly does not share an ethernet switch without your device (unless this is your under-development blog), so a path of machines, better known as a route, is determined, through which the packet of data will be forwarded, from one switch to another, until it eventually reaches the destination machine.

![ip packet](/ip_packet.png)

The route that packets take from your device maybe static or dynamic, with some packet switching techniques first deciding a path from source to destination, and then sending all packets down this path (known as **virtual circuit switching**), while others send packets down different paths, deciding dynamically at the time of sending each packet (known as datagram switching).

![packet switching](/packet_switching.png)

Additionally, the routes taken by packets sent from your device to a destination can vary for exterior factors, such as connecting a cell phone, which was previously routing traffic through a nearby cell tower to access the internet, to the Starbucks Wi-Fi, and thus, routing subsequent traffic through the coffee shop router.

### How does IP work?

At its core, the Internet as we know it is a web of physical networks such as the one, we have been tasked with building, where at least one machine in each of these networks is serving as a router, and is connected to another networks, creating a bridge between these networks over which data can flow, and all together, forming a globally interconnected network.

Host machines are identified using **IP addresses**, where a single host can have multiple IP addresses, one per network interface. Originally, IP addresses used the IPv4 standard, where each is a 32-bit number, usually written as 4 period separated 8-bit numbers (e.g., 192.168.2.12). IPv6, a newer standard with a larger range of IP addresses, writes addresses in the form of 8 colon separated groups of 2 bytes, each written as 4 hexadecimal digits ( e.g., 2001:0aaf:0123:aabf:0000:2052a42a:aa00).

Routers are the shepherds of packets, determining, based on the destination IP addresses stored in packets whether these are addressed to a host which is part of the same network as the router (in which case the packet can be forwarded appropriately), or whether another hop is needed from this router to another, to find the destination. For the latter case, routers maintain **forwarding tables**, which map ranges of IP addresses to specific next hop routers, from which the router decides accordingly.

### Subnets

Subnets are one of the keys to routing IP traffic efficiently and easily. We can define a subnet as a range of IP addresses, which results from applying a 32-bit (for IPv4) subnet mask to an IP address (using a bitwise AND operation between the IP address and subnet). For example, consider the following IP address the subnet mask **255.255.255.0**. For this subnet, when we apply a bitwise AND operation between it and any IP address, the result will leave the entire IP address unchanged but the last 8 bits (or single number in dot notation). This subnet mask thus defines a set of subnets of IP addresses where the first 24 bits (or 3 numbers in dot notation match). For example, the subnet **192.168.2.0/24** (where /24 is a shorthand way of saying the first 24 bits of the subnet mask are 1 -> 255.255.255.0) is the set of IP addresses which start with **192.168.2**.

Subnets are crucial to IP for a variety of reasons, but for now we will simply highlight one of the key reasons, which is that we can indicate that a particular interface of a router serves traffic for a subnet, rather than just a single IP address. If we were to have a router with an interface that connect to a physical network where all IP addresses are in the same subnet, then we could simply configure this interface to handle any traffic to that subnet, at which point the packets would be received by the appropriate host for the specific destination address in that subnet.

![subnet](/subnetting.png)

### That's all great but...

The important takeaway, and the next step of our puzzle is the following: We now know that the Internet is formed by internetworking of physical networks, with routers that handle the switching of packets between these networks. We also know that these routing decisions are based on IP addresses, which identify hosts and help routers decide whether they can send packets to a destination in their physical network, or whether they should forward them to another router, the question we now need to answer is **how do we get IP addresses for our hosts**?

### Static IP and DHCP

The answer to our question is that we can either assign an IP address to our interfaces manually, or we can have one dynamically configured. The latter is the de facto approach used for most devices, and the protocol which is used to dynamically assign these addresses is known as DHCP, or dynamic host configuration protocol.

DHCP is a key protocol in the IP layer and requires a set of devices which serve as DHCP server, receiving DHCP requests from client who are looking to be assigned an IP address. Who typically serves as the DHCP serve in a network? If you guessed the router, then it looks like you’re catching on! Host configuration is one of the many services that routers handle for their network and allows for them to accomplish the goal of routing traffic to and from devices in the network.

For our router on the other hand, we have 3 virtual ethernet interfaces, connecting to each of the VLANs which we have created prior. We do not want to dynamically configure IPs to these interfaces, rather we want these interfaces to be static, which we can accomplish using the below configurations.

![net interfaces](/net_interfaces.png)

The above file, **/etc/network/interfaces**, is a way to configure network interfaces on a Linux machine. Each of the 3 configurations is indicating we will be using a static IP address with the **static** keyword following the interface name, and the addresses have the /24 subnet defined, which means we use a subnet mask of **255.255.255.0**, and forward traffic to the router with the following rules:

1. Traffic to 192.168.0.* routed to eth1
2. Traffic to 192.168.1.* routed to eth2
3. Traffic to 192.168.2.* routed to eth3

We can bring up each of the interfaces we have configured using

**sudo ifup <interface name>**

and after we do so, end up with a set of interfaces like below

![static ifconfig](/ifconfig_1.png)

If you’re paying attention, you’ll notice there is a 4th interface that we did not configure manually, **eth0**. If you remember from last time, we had a 4th interface which connected our router to a **shared ethernet switch** with the outgoing ethernet connection of our host machine, and an IP address has already been dynamically assigned to this interface by, you guessed it, DHCP! The router serving traffic for our host is the DHCP server in this case, and in a similar vein, we will now need to set up a DHCP server on our router VM, to serve as the DHCP server for the VMs in our subnets.

### Setting up a DHCP server

We can install DHCP on Ubuntu via

**sudo apt install isc-dhcp-server.**

Once we have done so, we will rely on 2 key configuration files to set up our DHCP server.

![dhcpd.conf](/dhcp_config.png)

The above file, **/etc/dhcp/dhcpd.conf** is the key configuration file for our DHCP server. It signifies general options such as the lease time of IP addresses leased by the DHCP server (DHCP assigned addresses aren’t permanent), the ranges of IP addresses allocated to DHCP clients, and other information such as the DNS server to respond back with to clients etc. For our case we simply will define **3 subnet rules**, one for each network interface on the router connected to one of the private switches.

For each subnet, we specify a range of valid IP addresses that the corresponding rule can assign to DHCP clients, as well as some other configurations, most notably, the router for those clients (which we set as the interface of the router that they share a switch with).

***It’s also worth noting that IP addresses assigned by each interface will be in the same subnet as that network interface. (e.g. interface 192.168.1.1 assigns IP addresses of form 192.168.1.\*, same for other two interfaces). This is important because it means any traffic intended for the interfaces assigned these IPs which goes to our router will be forwarded to the switch shared by those interfaces and the router, because of our earlier configuration of the subnets for each of the router’s network interfaces, which routes all traffic in the subnet to the corresponding interface.***

Once we have configured the behavior of our DHCP server, we must configure **/etc/default/isc-dhcp-server**, like below, to specify the interfaces to listen on for DHCP requests:

![dhcp nics](/dhcp_config2.png)

At which point we can restart the server using:

**Sudo systemctl restart isc-dhcp-server**

We will see output in **journalctl** like below, showing the interfaces we are listening on for DHCP requests, and some other configuration information

![journalctl dhcp](/dhcp_requests.png)

Now that we have our DHCP server up and running and listening for DHCP traffic on the 3 NICs it has connected to the private networks, we can configure each of the VMs to initiate a DHCP request and be allocated an IP address in the configured subnet. We can do this explicitly, by executing:

**sudo dhclient <interface name>**

Where the DHCP request results in the below traffic on the router (when we log traffic on a particular NIC with **sudo tcpdump -I <interface>**)

![dhcp tcpdump](/dhcp_tcpdump.png)

*Note the DHCP request comes from a MAC address, since we have not yet assigned an IP address to this interface.*

Since DHCP is the default protocol used to configure network interfaces for IP, we'll have likely already initiated a DHCP request on OS startup, and already have been assigned an IP address, as we see below.

![dhcp on start](/dynamic_ifconfig.png)

The **dynamic** tag for the IP address of this interface indicates this is a dynamic IP address allocation (as opposed to that static IP addresses we employed for the 3 interfaces on our router).

### Is that it?

Obviously not! If you think it was that easy then you don’t know the firs thing about writing a blog series (hint: there’s usually more than 2 parts). Let’s take stock of where we are at now though, we have:

1. Set up static IP addresses for our routers’ network interfaces
2. Configured a DHCP configuration which listens for DHCP traffic on each of the above interfaces, and assigned IP addresses to clients in the same subnet at the interface on which the request was received
3. Confirmed that, on startup, we have a dynamically configured IP for the interfaces on our VLAN VMs
4. If we try pinging two VMs in the same network via their IP addresses, we will see that this works without issues, amazing

![ping vlan](/vlan_ping.png)

So, what’s the problem? Despite being able to communicate over IP between devices in the same subnet (which based on our DHCP subnet rules is a set of interfaces attached to the same switch) if we try to ping VMs in the other VLANs by their IP address, this will fail, and furthermore, if we try to ping IP addresses of other hosts on the internet, or a **domain name**, such as microsoft.com, this will fail too! We’ve come a layer up in the network stack, but in many ways we are back to square one, lacking the ability to span across separated networks using IP, and yet again having very little semblance of what we’d look at as a router.

### Looking Forward

So far, we have been able to set up a scheme to assign and identify interfaces by IP addresses, either statically or dynamically. The unfortunate reality however is we are still a bit away from being able to communicate across networks as we described that IP allow us to do. Next time we’ll continue to extend our usage of IP to solve this problem, and continue on our way to building a router.