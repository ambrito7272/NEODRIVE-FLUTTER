# NEODRIVE — Reconstrução Visual — Etapa 1

Esta versão inicia a reconstrução do painel digital com uma arquitetura gráfica unificada.

## O que foi feito

- Preservados os modelos `VehicleData`, `VehicleConfig` e `AlarmConfig`.
- Eliminado o `DashboardController` duplicado.
- Criado um único `DashboardController` para dados e simulação.
- Eliminadas as implementações antigas duplicadas de velocímetro/conta-giros/painter.
- Criado o motor `NeoGauge` com `CustomPainter` e geometria baseada no tamanho disponível.
- Criado `NeoGlassPanel` para a linguagem visual do painel.
- Reconstruído o Dashboard em uma estrutura responsiva.
- Mantida uma simulação de dados para permitir desenvolvimento sem ESP32.
- Removido `flutter_screenutil` da etapa gráfica inicial; a geometria dos instrumentos usa `Canvas`/`Size`.
- Criado teste básico de renderização do Dashboard.

## Próximas etapas

1. Refinar a geometria para coincidir com a imagem de referência.
2. Criar as escalas específicas de RPM e km/h.
3. Criar os sete instrumentos secundários com o mesmo motor gráfico.
4. Implementar combustível, trip, odômetro e status.
5. Implementar alarmes e estados normal/warning/critical.
6. Criar configuração persistente.
7. Criar fonte de dados abstrata e integrar Bluetooth/ESP32.
8. Executar `flutter analyze`, `flutter test` e `flutter run` no ambiente Flutter do usuário.

## Importante

Esta é a primeira etapa da reconstrução. Ela substitui a camada visual antiga e estabelece a fundação gráfica. Não é ainda a versão final do painel nem a integração com sensores reais.
