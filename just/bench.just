# Benchmark wifi performance
[group('bench')]
wifi *args:
    wifi-bench {{ args }}

# Benchmark bluetooth performance
[group('bench')]
bt *args:
    bt-bench {{ args }}
