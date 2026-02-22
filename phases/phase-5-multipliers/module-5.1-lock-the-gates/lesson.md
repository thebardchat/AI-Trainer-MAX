# Module 5.1 — Lock the Gates

## WHAT YOU'LL BUILD

A network-level security audit of your AI system. You'll scan your machine's open ports, check whether Ollama, Weaviate, and the MCP server are exposed to your local network or locked to localhost, verify your Windows Firewall is active, and generate a hardening report you can act on.

Module 3.4 taught you to read the security logs. This module teaches you to check the locks on the doors themselves. Reading logs tells you what already happened. Scanning ports tells you what COULD happen. That's the difference between reviewing the security camera footage and actually walking the fence line.

You are no longer a student. You are a multiplier. The person who secures their own system and then teaches their family to do the same.

---

## KEY TERMS

- **Port**: A numbered channel on your computer where a service listens for connections. Think of it like a loading dock door at a warehouse. Door 11434 is where Ollama receives requests. Door 8080 is Weaviate. Door 8100 is your MCP server. Every open door is a potential entry point.

- **netstat**: A built-in Windows command that shows every active network connection and listening port on your machine. It's your clipboard walk-around — you can see exactly which doors are open and who's standing at them.

- **Binding Address (0.0.0.0 vs 127.0.0.1)**: When a service binds to `127.0.0.1`, it only accepts connections from your own machine. When it binds to `0.0.0.0`, it accepts connections from ANY device on your network. The difference is like having a front door that only opens from inside versus one that opens from the street.

- **Windows Firewall**: The built-in gatekeeper that decides which network traffic gets in and out. Even if a service binds to 0.0.0.0, the firewall can still block outside connections. It's your second line of defense — the fence around the property, even if a door is unlocked.

- **netsh advfirewall**: The command-line tool for checking and managing Windows Firewall rules. It shows you whether the firewall is on, what profile is active, and what the default policy is for incoming connections.

- **Hardening**: The process of reducing your system's attack surface — closing unnecessary ports, binding services to localhost, enabling firewalls, and documenting what's exposed. Like reinforcing the walls and locking every door before you leave for the night.

---

## THE LESSON

### Step 1: Know what doors are open

Every service you run opens a port. Ollama opens 11434. Weaviate opens 8080. The MCP server opens 8100. Those are the doors to your AI system.

The question isn't whether doors are open — they have to be for the system to work. The question is: who can reach them?

Run this in your terminal:

```
netstat -an | findstr "LISTENING"
```

This shows every port your machine is actively listening on. You'll see lines like:

```
TCP    127.0.0.1:11434    0.0.0.0:0    LISTENING
TCP    0.0.0.0:8080       0.0.0.0:0    LISTENING
```

The first column after TCP is the key. That's the binding address and port.

### Step 2: Understand what the binding address means

- `127.0.0.1:11434` — Ollama is listening, but ONLY from this machine. Nobody on your Wi-Fi can reach it. Good.
- `0.0.0.0:8080` — Weaviate is listening from ANYWHERE on the network. Any device on your Wi-Fi could connect. That might be intentional (if you run a multi-device setup) or a risk (if you didn't mean to expose it).

This is the most important check in this module. A service bound to 0.0.0.0 is like a loading dock door that faces the public road. It might be fine if you have a guard posted. It's a problem if you didn't know it was open.

### Step 3: Check the firewall

Even if a service is bound to 0.0.0.0, Windows Firewall can block outside access. Run:

```
netsh advfirewall show currentprofile
```

You want to see:

```
State                                 ON
Firewall Policy                       BlockInbound,AllowOutbound
```

"State ON" means the firewall is active. "BlockInbound" means incoming connections are blocked by default — services have to be explicitly allowed through. That's the right configuration for a home AI system.

If the state is OFF, your machine is accepting all incoming connections. Fix that immediately.

### Step 4: Build the hardening report

Now you put it together. For each of your three AI services, answer:

1. Is the port open? (netstat shows LISTENING)
2. Is it bound to localhost or the network? (127.0.0.1 vs 0.0.0.0)
3. Is the firewall blocking outside access? (State ON + BlockInbound)

If a service is bound to 0.0.0.0 AND the firewall is off — that's a red flag. Anyone on your network can reach that service.

If a service is bound to 127.0.0.1 — it doesn't matter what the firewall says. Nobody external can reach it regardless.

The exercise will walk you through this check-by-check and generate a summary report.

### Step 5: Log what you found

After the audit, you'll log the results through the MCP server using `system_health`. This creates a record that your system was checked on this date. When you're teaching someone else to do this — your son, your neighbor, your church group — you'll want them to build this same habit.

---

## THE PATTERN

```
SCAN PORTS        ->  CHECK BINDINGS     ->  VERIFY FIREWALL  ->  HARDENING REPORT
(netstat -an)         (127.0.0.1 vs           (netsh advfirewall)    (document + log)
                       0.0.0.0)
```

Four steps. Each one answers a specific question. Together they tell you exactly how exposed your AI system is.

---

## WHAT YOU PROVED

- You can scan your machine's open ports with netstat
- You understand the difference between localhost-only and network-exposed services
- You can verify Windows Firewall is active and blocking inbound connections
- You generated a hardening report documenting your system's security posture
- You know how to find and fix exposed services before someone else finds them

**Next:** Run `exercise.bat`
