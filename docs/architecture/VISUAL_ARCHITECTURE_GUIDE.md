# AI Workflow Automation - Visual Architecture Guide

**Version**: 4.0.1  
**Last Updated**: 2026-02-10  
**Purpose**: Visual representation of system architecture, component relationships, and data flows

> 📋 **Companion Documents**:
> - [PROJECT_REFERENCE.md](../PROJECT_REFERENCE.md) - Project statistics and features
> - [COMPREHENSIVE_ARCHITECTURE_GUIDE.md](COMPREHENSIVE_ARCHITECTURE_GUIDE.md) - Detailed architecture
> - [SCRIPT_REFERENCE.md](../../src/workflow/SCRIPT_REFERENCE.md) - Script API reference

---

## Table of Contents

1. [System Overview](#system-overview)
2. [High-Level Architecture](#high-level-architecture)
3. [Module Architecture](#module-architecture)
4. [Workflow Pipeline](#workflow-pipeline)
5. [AI Integration Architecture](#ai-integration-architecture)
6. [Data Flow Diagrams](#data-flow-diagrams)
7. [Performance Optimization Flow](#performance-optimization-flow)
8. [Dependency Graph](#dependency-graph)

---

## System Overview

### Component Hierarchy

```mermaid
graph TB
    subgraph "User Interface"
        CLI[Command Line Interface]
        Templates[Workflow Templates]
        IDE[IDE Integration]
    end
    
    subgraph "Orchestration Layer"
        Main[Main Orchestrator<br/>execute_tests_docs_workflow.sh]
        PreFlight[Pre-Flight Orchestrator]
        Validation[Validation Orchestrator]
        Quality[Quality Orchestrator]
        Final[Finalization Orchestrator]
    end
    
    subgraph "Core Modules Layer"
        AI[AI Helpers<br/>17 Personas]
        Tech[Tech Stack<br/>Detection]
        Opt[Workflow<br/>Optimization]
        Change[Change<br/>Detection]
        Metrics[Metrics<br/>Collection]
    end
    
    subgraph "Supporting Modules Layer"
        Cache[AI Cache]
        Session[Session<br/>Manager]
        Config[Configuration<br/>Wizard]
        Health[Health<br/>Check]
    end
    
    subgraph "Step Execution Layer"
        Steps[23 Step Modules]
        Step0a[Pre-Processing]
        Step0b[Bootstrap Docs]
        Step1[Documentation]
        Step5[Testing]
        Step11_7[Front-End Dev]
        Step15[UX Analysis]
    end
    
    subgraph "External Systems"
        Git[Git Repository]
        Copilot[GitHub Copilot CLI]
        FS[File System]
    end
    
    CLI --> Main
    Templates --> Main
    IDE --> Main
    
    Main --> PreFlight
    Main --> Validation
    Main --> Quality
    Main --> Final
    
    PreFlight --> Tech
    PreFlight --> Change
    PreFlight --> Config
    PreFlight --> Health
    
    Validation --> Steps
    Quality --> Steps
    Final --> Steps
    
    Steps --> Step0a
    Steps --> Step0b
    Steps --> Step1
    Steps --> Step5
    Steps --> Step11_7
    Steps --> Step15
    
    AI --> Copilot
    Tech --> FS
    Change --> Git
    Metrics --> FS
    Cache --> FS
    
    Step1 --> AI
    Step5 --> AI
    Step11_7 --> AI
    Step15 --> AI
    
    Opt --> Cache
    Opt --> Session
```

---

## High-Level Architecture

### System Layers

```mermaid
graph LR
    subgraph "Entry Layer"
        A[User Command]
        B[CLI Arguments]
    end
    
    subgraph "Orchestration Layer"
        C[Main Orchestrator]
        D[4 Sub-Orchestrators]
    end
    
    subgraph "Business Logic Layer"
        E[81 Library Modules]
        F[Core Modules]
        G[Supporting Modules]
    end
    
    subgraph "Execution Layer"
        H[23 Step Modules]
        I[Configuration-Driven]
    end
    
    subgraph "Integration Layer"
        J[AI Integration]
        K[Git Integration]
        L[File System]
    end
    
    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    E --> G
    F --> H
    G --> H
    H --> I
    I --> J
    I --> K
    I --> L
```

### Architecture Principles

1. **Functional Core / Imperative Shell**
   - Pure functions in library modules
   - Side effects isolated to step execution
   - Testable and composable

2. **Single Responsibility**
   - Each module has one clear purpose
   - Clean separation of concerns
   - Modular design

3. **Configuration as Code**
   - YAML-based configuration
   - Centralized management
   - Environment overrides

---

## Module Architecture

### Module Organization

```mermaid
graph TB
    subgraph "Library Modules (81 total)"
        subgraph "Core Modules (12)"
            ai_helpers[ai_helpers.sh<br/>102K, 17 personas]
            tech_stack[tech_stack.sh<br/>47K]
            workflow_opt[workflow_optimization.sh<br/>31K]
            project_kind[project_kind_config.sh<br/>26K]
            change_detect[change_detection.sh<br/>17K]
            metrics[metrics.sh<br/>16K]
        end
        
        subgraph "Supporting Modules (69)"
            edit_ops[edit_operations.sh<br/>14K]
            ai_cache[ai_cache.sh<br/>11K]
            session_mgr[session_manager.sh<br/>12K]
            doc_template[doc_template_validator.sh<br/>13K]
            config_wizard[config_wizard.sh<br/>16K]
            health_check[health_check.sh<br/>15K]
        end
    end
    
    subgraph "Step Modules (23 total)"
        step_0a[step_0a_pre_process.sh<br/>Pre-Processing]
        step_0b[step_0b_bootstrap.sh<br/>Bootstrap Docs]
        step_01[documentation_updates.sh<br/>Step 1]
        step_05[test_execution.sh<br/>Step 5]
        step_11_7[front_end_development.sh<br/>Step 11.7]
        step_15[ux_analysis.sh<br/>Step 15]
        step_16[post_processing.sh<br/>Step 16]
    end
    
    subgraph "Orchestrators (4 total)"
        pre_flight[pre_flight.sh<br/>Initialization]
        validation[validation.sh<br/>Validation Stage]
        quality[quality.sh<br/>Quality Stage]
        finalization[finalization.sh<br/>Finalization]
    end
    
    ai_helpers --> step_01
    ai_helpers --> step_05
    ai_helpers --> step_11_7
    ai_helpers --> step_15
    
    workflow_opt --> pre_flight
    change_detect --> pre_flight
    tech_stack --> pre_flight
    
    pre_flight --> validation
    validation --> quality
    quality --> finalization
```

---

## Workflow Pipeline

### 23-Step Pipeline Flow

```mermaid
graph TD
    Start([Start Workflow]) --> PreFlight[Pre-Flight Checks]
    
    PreFlight --> Step0a[Step 0a: Pre-Processing<br/>Initialize environment]
    Step0a --> Step0b[Step 0b: Bootstrap Docs<br/>Generate missing docs]
    
    Step0b --> Stage1{Multi-Stage<br/>Pipeline?}
    
    Stage1 -->|Stage 1: Core| Step00[Step 0: Change Analysis]
    Step00 --> Step01[Step 1: Documentation Updates]
    Step01 --> Step02[Step 2: Documentation Analysis]
    Step02 --> Step02_5[Step 2.5: Doc Optimization]
    Step02_5 --> Step03[Step 3: Documentation Review]
    
    Step03 --> Check1{Smart<br/>Execution?}
    Check1 -->|Skip| Stage2
    Check1 -->|Run| Step04[Step 4: Test Review]
    
    Step04 --> Stage2{Continue to<br/>Stage 2?}
    
    Stage2 -->|Stage 2: Extended| Step05[Step 5: Test Execution]
    Step05 --> Step06[Step 6: Coverage Analysis]
    Step06 --> Step07[Step 7: Test Generation]
    Step07 --> Step08[Step 8: Code Quality]
    
    Step08 --> Check2{Smart<br/>Execution?}
    Check2 -->|Skip| Stage3
    Check2 -->|Run| Step09[Step 9: Security Check]
    
    Step09 --> Step10[Step 10: Performance]
    Step10 --> Step11[Step 11: Source Code]
    Step11 --> Step11_7[Step 11.7: Front-End Dev]
    
    Step11_7 --> Stage3{Continue to<br/>Stage 3?}
    
    Stage3 -->|Stage 3: Finalization| Step12[Step 12: Final Review]
    Step12 --> Step13[Step 13: Integration]
    Step13 --> Step14[Step 14: Change Summary]
    Step14 --> Step15[Step 15: UX Analysis]
    Step15 --> Step16[Step 16: Post-Processing]
    Step16 --> Step17[Step 17: Git Finalization]
    
    Step17 --> Checkpoint{Checkpoint<br/>Success?}
    Checkpoint -->|Yes| Metrics[Collect Metrics]
    Checkpoint -->|Fail| Resume[Resume Available]
    
    Metrics --> Complete([Workflow Complete])
    Resume -.->|Next Run| Step00
    
    style Step0a fill:#e1f5ff
    style Step0b fill:#e1f5ff
    style Step01 fill:#ffe1e1
    style Step05 fill:#fff4e1
    style Step11_7 fill:#e1ffe1
    style Step15 fill:#f0e1ff
    style Step17 fill:#e1e1ff
```

### Stage-Based Execution

```mermaid
graph LR
    subgraph "Stage 1: Core Validation"
        S1_1[Change Analysis]
        S1_2[Documentation<br/>Updates]
        S1_3[Doc Analysis]
        S1_4[Doc Review]
    end
    
    subgraph "Stage 2: Extended Validation"
        S2_1[Test Execution]
        S2_2[Coverage<br/>Analysis]
        S2_3[Test Generation]
        S2_4[Code Quality]
        S2_5[Security]
        S2_6[Performance]
        S2_7[Source Code]
        S2_8[Front-End Dev]
    end
    
    subgraph "Stage 3: Finalization"
        S3_1[Final Review]
        S3_2[Integration]
        S3_3[Change Summary]
        S3_4[UX Analysis]
        S3_5[Post-Processing]
        S3_6[Git Finalization]
    end
    
    S1_1 --> S1_2
    S1_2 --> S1_3
    S1_3 --> S1_4
    
    S1_4 -->|Continue?| S2_1
    
    S2_1 --> S2_2
    S2_2 --> S2_3
    S2_3 --> S2_4
    S2_4 --> S2_5
    S2_5 --> S2_6
    S2_6 --> S2_7
    S2_7 --> S2_8
    
    S2_8 -->|Continue?| S3_1
    
    S3_1 --> S3_2
    S3_2 --> S3_3
    S3_3 --> S3_4
    S3_4 --> S3_5
    S3_5 --> S3_6
    
    style S1_1 fill:#ffe1e1
    style S1_2 fill:#ffe1e1
    style S1_3 fill:#ffe1e1
    style S1_4 fill:#ffe1e1
    
    style S2_1 fill:#fff4e1
    style S2_2 fill:#fff4e1
    style S2_3 fill:#fff4e1
    style S2_4 fill:#fff4e1
    style S2_5 fill:#fff4e1
    style S2_6 fill:#fff4e1
    style S2_7 fill:#fff4e1
    style S2_8 fill:#fff4e1
    
    style S3_1 fill:#e1ffe1
    style S3_2 fill:#e1ffe1
    style S3_3 fill:#e1ffe1
    style S3_4 fill:#e1ffe1
    style S3_5 fill:#e1ffe1
    style S3_6 fill:#e1ffe1
```

---

## AI Integration Architecture

### AI Persona System

```mermaid
graph TB
    subgraph "AI Integration Layer"
        Entry[AI Call Entry Point<br/>ai_call function]
        
        subgraph "Persona Management"
            Selector[Persona Selector]
            Builder[Prompt Builder]
            Config[YAML Config<br/>ai_helpers.yaml]
        end
        
        subgraph "17 AI Personas"
            P1[documentation_specialist]
            P2[code_reviewer]
            P3[test_engineer]
            P4[technical_writer]
            P5[front_end_developer]
            P6[ui_ux_designer]
            P7[security_analyst]
            P8[performance_analyst]
            P9[git_specialist]
            P10[integration_specialist]
            P11[quality_engineer]
            P12[accessibility_expert]
            P13[ml_optimization_analyst]
            P14[project_manager]
            P15[devops_engineer]
            P16[data_analyst]
            P17[configuration_specialist]
        end
        
        subgraph "Caching Layer"
            Cache[AI Response Cache<br/>24-hour TTL]
            Index[Cache Index<br/>SHA256 keys]
        end
        
        subgraph "External AI"
            Copilot[GitHub Copilot CLI<br/>claude-3-5-sonnet]
        end
    end
    
    Entry --> Selector
    Selector --> Config
    Config --> Builder
    
    Builder --> P1
    Builder --> P2
    Builder --> P3
    Builder --> P4
    Builder --> P5
    Builder --> P6
    Builder --> P7
    Builder --> P8
    Builder --> P9
    Builder --> P10
    Builder --> P11
    Builder --> P12
    Builder --> P13
    Builder --> P14
    Builder --> P15
    Builder --> P16
    Builder --> P17
    
    P1 --> Cache
    P2 --> Cache
    P3 --> Cache
    P4 --> Cache
    P5 --> Cache
    P6 --> Cache
    Cache --> Index
    
    Cache -->|Cache Miss| Copilot
    Copilot -->|Response| Cache
    Cache -->|Cache Hit| Entry
```

### AI Request Flow

```mermaid
sequenceDiagram
    participant Step as Step Module
    participant AI as ai_helpers.sh
    participant Cache as AI Cache
    participant Config as YAML Config
    participant Copilot as GitHub Copilot CLI
    
    Step->>AI: ai_call(persona, prompt, output)
    
    AI->>Cache: Check cache (SHA256 key)
    
    alt Cache Hit
        Cache->>AI: Return cached response
        AI->>Step: Write to output file
    else Cache Miss
        AI->>Config: Load persona prompt template
        Config->>AI: Return template
        
        AI->>AI: Build dynamic prompt
        AI->>Copilot: Send request
        
        Copilot->>AI: AI-generated response
        
        AI->>Cache: Store response (24h TTL)
        AI->>Step: Write to output file
    end
    
    Note over Cache: Auto-cleanup every 24h<br/>60-80% token savings
```

---

## Data Flow Diagrams

### Configuration Flow

```mermaid
graph LR
    subgraph "Configuration Sources"
        CLI[Command-Line<br/>Arguments]
        EnvFile[.workflow-config.yaml<br/>Project Config]
        CoreYAML[.workflow_core/config/<br/>YAML Files]
        Env[Environment<br/>Variables]
    end
    
    subgraph "Configuration Processing"
        Parser[YAML Parser<br/>yq processor]
        Merger[Config Merger]
        Validator[Config Validator]
    end
    
    subgraph "Configuration Consumers"
        Orchestrator[Main Orchestrator]
        Steps[Step Modules]
        AI[AI Personas]
        Opt[Optimizations]
    end
    
    CLI --> Merger
    EnvFile --> Parser
    CoreYAML --> Parser
    Env --> Merger
    
    Parser --> Merger
    Merger --> Validator
    
    Validator --> Orchestrator
    Validator --> Steps
    Validator --> AI
    Validator --> Opt
    
    style EnvFile fill:#ffe1e1
    style CoreYAML fill:#ffe1e1
```

### Change Detection Flow

```mermaid
graph TB
    Start([Git Repository]) --> Detect[Change Detection Module]
    
    Detect --> GitDiff[Git Diff Analysis]
    GitDiff --> FileTypes{Analyze File Types}
    
    FileTypes -->|Documentation| DocChanges[Documentation<br/>Changes]
    FileTypes -->|Source Code| CodeChanges[Code<br/>Changes]
    FileTypes -->|Tests| TestChanges[Test<br/>Changes]
    FileTypes -->|Config| ConfigChanges[Config<br/>Changes]
    
    DocChanges --> SmartExec[Smart Execution<br/>Decision Engine]
    CodeChanges --> SmartExec
    TestChanges --> SmartExec
    ConfigChanges --> SmartExec
    
    SmartExec --> StepSkip{Skip Steps?}
    
    StepSkip -->|Yes| Skip[Skip Unnecessary<br/>Steps<br/>40-85% faster]
    StepSkip -->|No| Run[Run All Steps]
    
    Skip --> Execute[Execute Workflow]
    Run --> Execute
    
    Execute --> Results([Results + Metrics])
    
    style DocChanges fill:#ffe1e1
    style CodeChanges fill:#fff4e1
    style TestChanges fill:#e1ffe1
    style ConfigChanges fill:#f0e1ff
```

### Metrics Collection Flow

```mermaid
graph LR
    subgraph "Metrics Sources"
        Step[Step Execution]
        Timer[Performance Timers]
        Cache[Cache Hit Rates]
        AI[AI Token Usage]
    end
    
    subgraph "Metrics Processing"
        Collect[Metrics Collector<br/>metrics.sh]
        Validate[Metrics Validator]
        Store[JSON Storage]
    end
    
    subgraph "Metrics Output"
        Current[current_run.json]
        History[history.jsonl]
        ML[ML Training Data<br/>.ml_data/]
        Reports[Performance<br/>Reports]
    end
    
    Step --> Collect
    Timer --> Collect
    Cache --> Collect
    AI --> Collect
    
    Collect --> Validate
    Validate --> Store
    
    Store --> Current
    Store --> History
    Store --> ML
    Store --> Reports
    
    ML --> Predictions[ML Predictions<br/>Future Runs]
```

---

## Performance Optimization Flow

### Optimization Decision Tree

```mermaid
graph TD
    Start([Workflow Start]) --> Analysis[Analyze Changes]
    
    Analysis --> Smart{Smart<br/>Execution<br/>Enabled?}
    
    Smart -->|Yes| ChangeType{Change<br/>Type?}
    Smart -->|No| Parallel{Parallel<br/>Execution<br/>Enabled?}
    
    ChangeType -->|Docs Only| Skip85[Skip 85%<br/>of steps]
    ChangeType -->|Code Only| Skip40[Skip 40%<br/>of steps]
    ChangeType -->|Full| Skip0[Run all<br/>steps]
    
    Skip85 --> Parallel
    Skip40 --> Parallel
    Skip0 --> Parallel
    
    Parallel -->|Yes| ML{ML<br/>Optimization<br/>Enabled?}
    Parallel -->|No| ML
    
    ML -->|Yes| MLPredict[ML Predictions<br/>15-30% faster]
    ML -->|No| MultiStage{Multi-Stage<br/>Pipeline?}
    
    MLPredict --> MultiStage
    
    MultiStage -->|Yes| Stage1[Run Stage 1<br/>Core Steps]
    MultiStage -->|No| Execute[Execute<br/>Workflow]
    
    Stage1 --> Continue1{Issues<br/>Found?}
    Continue1 -->|Yes| Results
    Continue1 -->|No| Stage2[Run Stage 2<br/>Extended Steps]
    
    Stage2 --> Continue2{Issues<br/>Found?}
    Continue2 -->|Yes| Results
    Continue2 -->|No| Stage3[Run Stage 3<br/>Finalization]
    
    Stage3 --> Results([Results])
    Execute --> Results
    
    style Skip85 fill:#e1ffe1
    style Skip40 fill:#fff4e1
    style MLPredict fill:#f0e1ff
```

### Performance Gains Breakdown

```mermaid
graph LR
    subgraph "Baseline (No Optimizations)"
        B[23 minutes]
    end
    
    subgraph "Smart Execution Only"
        S1[3.5 min<br/>Docs Only<br/>85% faster]
        S2[14 min<br/>Code Changes<br/>40% faster]
    end
    
    subgraph "Parallel Execution Only"
        P[15.5 min<br/>All Changes<br/>33% faster]
    end
    
    subgraph "Combined (Smart + Parallel)"
        C1[2.3 min<br/>Docs Only<br/>90% faster]
        C2[10 min<br/>Code Changes<br/>57% faster]
    end
    
    subgraph "With ML Optimization"
        M1[1.5 min<br/>Docs Only<br/>93% faster]
        M2[6-7 min<br/>Code Changes<br/>70-75% faster]
    end
    
    B --> S1
    B --> S2
    B --> P
    B --> C1
    B --> C2
    B --> M1
    B --> M2
    
    style M1 fill:#e1ffe1
    style M2 fill:#e1ffe1
```

---

## Dependency Graph

### Module Dependencies

```mermaid
graph TD
    subgraph "Entry Point"
        Main[execute_tests_docs_workflow.sh]
    end
    
    subgraph "Orchestrators"
        Pre[pre_flight.sh]
        Val[validation.sh]
        Qua[quality.sh]
        Fin[finalization.sh]
    end
    
    subgraph "Core Dependencies"
        AI[ai_helpers.sh]
        Tech[tech_stack.sh]
        Opt[workflow_optimization.sh]
        Change[change_detection.sh]
        Metrics[metrics.sh]
        Config[config_wizard.sh]
    end
    
    subgraph "Step Dependencies"
        Step0a[step_0a_pre_process.sh]
        Step0b[step_0b_bootstrap.sh]
        Step1[documentation_updates.sh]
        Step5[test_execution.sh]
        Step11_7[front_end_development.sh]
        Step15[ux_analysis.sh]
        Step17[git_finalization.sh]
    end
    
    Main --> Pre
    Main --> Val
    Main --> Qua
    Main --> Fin
    
    Pre --> Config
    Pre --> Tech
    Pre --> Change
    Pre --> Opt
    
    Val --> Step0a
    Val --> Step0b
    Val --> Step1
    Val --> Step5
    
    Qua --> Step11_7
    
    Fin --> Step15
    Fin --> Step17
    
    Step1 --> AI
    Step5 --> AI
    Step11_7 --> AI
    Step15 --> AI
    
    Opt --> Metrics
    Opt --> Change
```

### Step Execution Dependencies

```mermaid
graph TD
    Step0a[Step 0a: Pre-Process] --> Step0b[Step 0b: Bootstrap]
    Step0b --> Step0[Step 0: Analysis]
    
    Step0 --> Step1[Step 1: Docs Update]
    Step1 --> Step2[Step 2: Docs Analysis]
    Step2 --> Step2_5[Step 2.5: Optimize]
    Step2_5 --> Step3[Step 3: Docs Review]
    
    Step3 --> Step4[Step 4: Test Review]
    Step4 --> Step5[Step 5: Test Execution]
    Step5 --> Step6[Step 6: Coverage]
    Step6 --> Step7[Step 7: Test Gen]
    
    Step7 --> Step8[Step 8: Quality]
    Step8 --> Step9[Step 9: Security]
    Step9 --> Step10[Step 10: Performance]
    Step10 --> Step11[Step 11: Source]
    Step11 --> Step11_7[Step 11.7: Front-End]
    
    Step11_7 --> Step12[Step 12: Final Review]
    Step12 --> Step13[Step 13: Integration]
    Step13 --> Step14[Step 14: Summary]
    Step14 --> Step15[Step 15: UX]
    Step15 --> Step16[Step 16: Post-Process]
    Step16 --> Step17[Step 17: Git Final]
    
    style Step0a fill:#e1f5ff
    style Step0b fill:#e1f5ff
    style Step1 fill:#ffe1e1
    style Step5 fill:#fff4e1
    style Step11_7 fill:#e1ffe1
    style Step15 fill:#f0e1ff
    style Step17 fill:#e1e1ff
```

---

## Architecture Patterns

### Functional Core / Imperative Shell

```mermaid
graph TB
    subgraph "Imperative Shell (Side Effects)"
        Entry[Main Entry Point]
        Orch[Orchestrators]
        Steps[Step Modules]
        IO[I/O Operations]
    end
    
    subgraph "Functional Core (Pure Functions)"
        Lib[Library Modules]
        Transform[Data Transformations]
        Logic[Business Logic]
        Validate[Validation Functions]
    end
    
    Entry --> Orch
    Orch --> Steps
    Steps --> IO
    
    Steps --> Lib
    Lib --> Transform
    Lib --> Logic
    Lib --> Validate
    
    Transform --> Steps
    Logic --> Steps
    Validate --> Steps
```

### Module Communication Pattern

```mermaid
sequenceDiagram
    participant Main as Main Orchestrator
    participant Orch as Sub-Orchestrator
    participant Core as Core Module
    participant Step as Step Module
    participant Ext as External System
    
    Main->>Orch: Execute stage
    Orch->>Core: Initialize
    Core->>Core: Pure function processing
    Core->>Orch: Return result
    
    Orch->>Step: Execute step
    Step->>Core: Get configuration
    Core->>Step: Return config
    
    Step->>Ext: Perform I/O
    Ext->>Step: Response
    
    Step->>Orch: Step complete
    Orch->>Main: Stage complete
    
    Note over Main,Ext: Imperative shell at edges<br/>Functional core in middle
```

---

## Summary

This visual architecture guide provides:

1. **System Overview**: Component hierarchy and relationships
2. **High-Level Architecture**: System layers and principles
3. **Module Architecture**: Organization of 111 total modules
4. **Workflow Pipeline**: 23-step execution flow with stages
5. **AI Integration**: 17 personas and caching system
6. **Data Flows**: Configuration, change detection, metrics
7. **Performance**: Optimization decision tree and gains
8. **Dependencies**: Module and step relationships

**Key Takeaways**:
- Modular design with clear separation of concerns
- Functional core with imperative shell pattern
- Configuration-driven workflow execution
- Multi-stage progressive validation
- AI-powered analysis with caching
- Performance optimizations achieve 93% speed improvement

**Related Documentation**:
- [COMPREHENSIVE_ARCHITECTURE_GUIDE.md](COMPREHENSIVE_ARCHITECTURE_GUIDE.md) - Detailed architecture
- [../PROJECT_REFERENCE.md](../PROJECT_REFERENCE.md) - Project statistics
- [../../src/workflow/SCRIPT_REFERENCE.md](../../src/workflow/SCRIPT_REFERENCE.md) - Script API
- [../reference/workflow-diagrams.md](../reference/workflow-diagrams.md) - Additional diagrams

---

**Last Updated**: 2026-02-10  
**Maintainer**: Marcelo Pereira Barbosa ([@mpbarbosa](https://github.com/mpbarbosa))
