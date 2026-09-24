# NEODRIVE — Premium Digital Instrument Cluster

Esta etapa reconstrói o Dashboard principal como um instrument cluster digital automotivo, usando Flutter/Canvas em vez de uma coleção de widgets genéricos.

## Instrumentos principais

1. Velocímetro — 0–220 km/h
2. Conta-giros — 0–8.000 RPM
3. Pressão do óleo — bar
4. Temperatura do motor — °C
5. Tensão da bateria — V
6. Vacuômetro — kPa
7. Amperímetro — A
8. Lambda/AFR — AFR

## Gráficos principais

`lib/widgets/gauges/premium_gauge.dart` implementa:

- CustomPainter/Canvas;
- abertura do arco para baixo;
- escala matemática e subdivisões;
- zonas normal/atenção/crítica;
- gradientes;
- bezel e profundidade;
- ponteiro multicamada;
- halo e glow;
- rastro angular dinâmico com persistência curta;
- cor do rastro vinculada ao estado;
- RepaintBoundary;
- Semantics para testes e acessibilidade.

## Arquitetura ativa

```text
main.dart
   ↓
DashboardController
   ↓
VehicleData / VehicleConfig
   ↓
DashboardScreen
   ├── PremiumGauge × 2
   └── PremiumMetricCard × 6

Futuro:
VehicleDataSource
   ↓
Bluetooth / ESP32
```

## Validação local

No computador com Flutter SDK instalado:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Esta entrega foi revisada estaticamente no ambiente de produção do arquivo. O ambiente que gerou o ZIP não possui o SDK Flutter/Dart instalado; portanto `flutter analyze`, `flutter test` e renderização do Chrome devem ser confirmados no ambiente local antes de declarar a etapa como homologada.

## ETAPA SEGUINTE — REFINAMENTO VISUAL E FUNCIONAL

Esta versão adiciona:
- indicador auxiliar de combustível de 0–100%;
- combustível no modelo VehicleData e VehicleConfig;
- simulação gradual do nível de combustível;
- correção do teste para `pumpWidget`;
- aro dos gauges com gradiente integrado verde → amarelo → laranja → vermelho;
- abertura geométrica do arco voltada para baixo;
- rastro angular e halo refinados;
- redução do custo de renderização do arco, usando um único SweepGradient em vez de dezenas de segmentos.

Observação: o ambiente desta entrega não possui o SDK Flutter instalado. A homologação final deve ser feita no computador de desenvolvimento com `flutter analyze`, `flutter test` e `flutter run -d chrome`.
