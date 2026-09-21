# sysnet-probe

`sysnet-probe` é um utilitário CLI modular desenvolvido em Bash para inspeção de métricas de sistema, auditoria de processos e diagnóstico de rede em ambientes Linux nativos.

---

## Recursos e Funcionalidades

- **Inspeção de Recursos do Sistema (`--system`)**:
  - Leitura de uso de memória física e Swap via `free`.
  - Cálculo de utilização percentual de CPU e tempo em idle via `top`.
  - Médias de carga (*Load Averages*) de 1, 5 e 15 minutos via `/proc/loadavg`.

- **Auditoria de Processos (`--process <name>`)**:
  - Localização precisa de PIDs ativos por nome exato via `pgrep -x`.
  - Relatório detalhado por instância: PID, Usuário proprietário, % CPU, % Memória e Comando via `ps`.

- **Conectividade e Diagnóstico de Rede (`--network <host>`)**:
  - Teste de conectividade ICMP com extração de perda de pacotes e latência média (*RTT avg*) via `ping`.
  - Resolução de nomes DNS com extração de registros A via `dig +short`.

- **Varredura de Portas TCP (`--ports <host>`)**:
  - Checagem rápida de portas comuns (22/SSH, 80/HTTP, 443/HTTPS) utilizando o pseudo-dispositivo nativo `/dev/tcp` com controle de timeout.

- **Suíte de Testes Automatizada (`tests/test_probe.sh`)**:
  - Testes unitários e de integração com asserções de código de saída e validação de padrões de saída.

---

## Arquitetura do Projeto

```text
sysnet-probe/
├── LICENSE              # Licença MIT
├── README.md            # Documentação técnica
├── sysnet-probe.sh      # Ponto de entrada (CLI router e parse de flags)
├── lib/
│   ├── system.sh        # Módulo de métricas de sistema e processos
│   └── network.sh       # Módulo de conectividade, DNS e varredura de portas
└── tests/
    └── test_probe.sh    # Suíte de testes automatizados e asserções
