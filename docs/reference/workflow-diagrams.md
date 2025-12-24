# Workflow Automation Visual Diagrams

**Version**: 2.4.0  
**Created**: 2025-12-23  
**Purpose**: Visual documentation for complex workflow concepts

This document provides visual diagrams using Mermaid to explain the complex workflows, dependencies, and execution patterns in the AI Workflow Automation system.

---

## Table of Contents

1. [15-Step Workflow Flow](#15-step-workflow-flow)
2. [Dependency Relationships](#dependency-relationships)
3. [Parallel Execution Groups](#parallel-execution-groups)
4. [Change Detection Logic](#change-detection-logic)
5. [Smart Execution Decision Tree](#smart-execution-decision-tree)
6. [AI Cache Flow](#ai-cache-flow)
7. [Checkpoint Resume Logic](#checkpoint-resume-logic)
8. [Module Architecture](#module-architecture)

---

## 15-Step Workflow Flow

### Sequential Execution (Baseline)

```mermaid
graph TD
    Start([Workflow Start]) --> Step0[Step 0: Pre-Analysis<br/>30s]
    Step0 --> Step1[Step 1: Documentation Updates<br/>120s]
    Step1 --> Step2[Step 2: Consistency Analysis<br/>90s]
    Step2 --> Step3[Step 3: Script Reference Validation<br/>60s]
    Step3 --> Step4[Step 4: Directory Structure Validation<br/>90s]
    Step4 --> Step5[Step 5: Test Review<br/>120s]
    Step5 --> Step6[Step 6: Test Generation<br/>180s]
    Step6 --> Step7[Step 7: Test Execution<br/>240s]
    Step7 --> Step8[Step 8: Dependency Validation<br/>60s]
    Step8 --> Step9[Step 9: Code Quality<br/>150s]
    Step9 --> Step10[Step 10: Context Analysis<br/>120s]
    Step10 --> Step12[Step 12: Markdown Linting<br/>45s]
    Step12 --> Step13[Step 13: Prompt Engineering<br/>150s]
    Step13 --> Step14[Step 14: UX Analysis<br/>180s]
    Step14 --> Step11[Step 11: Git Finalization FINAL<br/>90s]
    Step11 --> End([Workflow Complete])
    
    style Start fill:#90EE90
    style End fill:#87CEEB
    style Step7 fill:#FFB6C1
    style Step11 fill:#FFD700
    style Step14 fill:#FFE4B5
    
    classDef aiStep fill:#E6E6FA
    class Step1,Step5,Step6,Step9,Step10,Step11,Step13,Step14 aiStep
```

**Total Sequential Time**: ~1,545 seconds (~26 minutes)

---

## Dependency Relationships

### Complete Dependency Graph

```mermaid
graph TD
    Step0[Step 0: Pre-Analysis<br/>~30s]
    Step1[Step 1: Documentation<br/>~120s]
    Step2[Step 2: Consistency<br/>~90s]
    Step3[Step 3: Script Refs<br/>~60s]
    Step4[Step 4: Directory<br/>~90s]
    Step5[Step 5: Test Review<br/>~120s]
    Step6[Step 6: Test Gen<br/>~180s]
    Step7[Step 7: Test Exec<br/>~240s]
    Step8[Step 8: Dependencies<br/>~60s]
    Step9[Step 9: Code Quality<br/>~150s]
    Step10[Step 10: Context<br/>~120s]
    Step11[Step 11: Git Final<br/>~90s]
    Step12[Step 12: Markdown<br/>~45s]
    Step13[Step 13: Prompt Eng<br/>~150s]
    Step14[Step 14: UX Analysis<br/>~180s]
    
    %% Pre-Analysis dependencies
    Step0 --> Step1
    Step0 --> Step3
    Step0 --> Step4
    Step0 --> Step5
    Step0 --> Step8
    Step0 --> Step13
    Step0 --> Step14
    
    %% Documentation track
    Step1 --> Step2
    Step2 --> Step12
    Step2 --> Step10
    
    %% Test pipeline
    Step5 --> Step6
    Step6 --> Step7
    Step7 --> Step9
    
    %% Context analysis convergence
    Step1 --> Step10
    Step3 --> Step10
    Step4 --> Step10
    Step7 --> Step10
    Step8 --> Step10
    Step9 --> Step10
    
    %% Validation and analysis steps before finalization
    Step1 --> Step14
    Step2 --> Step12
    Step10 --> Step12
    Step12 --> Step13
    Step13 --> Step14
    
    %% Git Finalization - MUST BE LAST
    Step10 --> Step11
    Step12 --> Step11
    Step13 --> Step11
    Step14 --> Step11
    
    style Step0 fill:#90EE90
    style Step7 fill:#FFB6C1
    style Step10 fill:#FFE4B5
    style Step11 fill:#87CEEB
    
    classDef parallel1 fill:#E6E6FA
    classDef parallel2 fill:#F0E68C
    class Step1,Step3,Step4,Step5,Step8,Step13,Step14 parallel1
    class Step2,Step12 parallel2
```

### Critical Path (Longest Sequential Chain)

```mermaid
graph LR
    Step0[Pre-Analysis<br/>30s] --> Step5[Test Review<br/>120s]
    Step5 --> Step6[Test Gen<br/>180s]
    Step6 --> Step7[Test Exec<br/>240s]
    Step7 --> Step10[Context<br/>120s]
    Step10 --> Step12[Markdown<br/>45s]
    Step12 --> Step13[Prompt Eng<br/>150s]
    Step13 --> Step14[UX Analysis<br/>180s]
    Step14 --> Step11[Git Final<br/>90s]
    
    style Step7 fill:#FFB6C1
    style Step6 fill:#FFE4B5
    style Step11 fill:#FFD700
```

**Critical Path Duration**: ~1,155 seconds (~19 minutes)

---

## Parallel Execution Groups

### 3-Track Parallel Execution

```mermaid
graph TD
    Start([Start]) --> Step0[Step 0: Pre-Analysis<br/>30s]
    
    Step0 --> Track1[Track 1: Analysis]
    Step0 --> Track2[Track 2: Validation]
    Step0 --> Track3[Track 3: Documentation]
    
    %% Track 1: Analysis
    Track1 --> Group1A[Steps 3, 4, 13<br/>Parallel: 150s]
    Group1A --> Step10[Step 10: Context<br/>120s]
    
    %% Track 2: Validation
    Track2 --> Group2A[Steps 5, 8<br/>Parallel: 120s]
    Group2A --> Step6[Step 6: Test Gen<br/>180s]
    Step6 --> Step7[Step 7: Test Exec<br/>240s]
    Step7 --> Step9[Step 9: Code Quality<br/>150s]
    Step9 --> Sync2[Sync Point]
    
    %% Track 3: Documentation
    Track3 --> Group3A[Steps 1, 14<br/>Parallel: 180s]
    Group3A --> Step2[Step 2: Consistency<br/>90s]
    Step2 --> Step12[Step 12: Markdown<br/>45s]
    Step12 --> Step13[Step 13: Prompt Eng<br/>150s]
    Step13 --> Sync3[Sync Point]
    
    %% Final synchronization
    Step10 --> FinalSync[Final Sync]
    Sync2 --> FinalSync
    Sync3 --> FinalSync
    FinalSync --> Step11[Step 11: Git Final FINAL<br/>90s]
    Step11 --> End([Complete])
    
    style Start fill:#90EE90
    style End fill:#87CEEB
    style Step7 fill:#FFB6C1
    style FinalSync fill:#FFD700
    
    classDef track1 fill:#E6E6FA
    classDef track2 fill:#FFE4B5
    classDef track3 fill:#B0E0E6
    class Track1,Group1A,Step10 track1
    class Track2,Group2A,Step6,Step7,Step9 track2
    class Track3,Group3A,Step2,Step12 track3
```

### Parallel Group Details

```mermaid
graph TD
    Step0[Step 0: Pre-Analysis<br/>30s Complete] --> ParallelStart{Parallel Groups}
    
    %% Group 1: Independent validation
    ParallelStart --> Group1[Group 1: Independent Validation]
    Group1 --> Step1[Step 1: Documentation<br/>120s]
    Group1 --> Step3[Step 3: Script Refs<br/>60s]
    Group1 --> Step4[Step 4: Directory<br/>90s]
    Group1 --> Step5[Step 5: Test Review<br/>120s]
    Group1 --> Step8[Step 8: Dependencies<br/>60s]
    Group1 --> Step13[Step 13: Prompt Eng<br/>150s]
    Group1 --> Step14[Step 14: UX Analysis<br/>180s]
    
    Step1 --> Sync1[Sync Point]
    Step3 --> Sync1
    Step4 --> Sync1
    Step5 --> Sync1
    Step8 --> Sync1
    Step13 --> Sync1
    Step14 --> Sync1
    
    %% Group 2: Documentation checks
    Sync1 --> Group2[Group 2: Documentation]
    Group2 --> Step2[Step 2: Consistency<br/>90s]
    Group2 --> Step12[Step 12: Markdown<br/>45s]
    
    Step2 --> Sync2[Sync Point]
    Step12 --> Sync2
    
    %% Sequential completion
    Sync2 --> Step6[Step 6: Test Gen<br/>180s]
    Step6 --> Step7[Step 7: Test Exec<br/>240s]
    Step7 --> Step9[Step 9: Code Quality<br/>150s]
    Step9 --> Step10[Step 10: Context<br/>120s]
    Step10 --> Step11[Step 11: Git Final<br/>90s]
    
    style Group1 fill:#E6E6FA
    style Group2 fill:#FFE4B5
    style Sync1 fill:#FFD700
    style Sync2 fill:#FFD700
    style Step7 fill:#FFB6C1
```

**Parallel Execution Time**: ~930 seconds (~15.5 minutes)  
**Time Savings**: ~465 seconds (~8 minutes, **33% faster**)

---

## Change Detection Logic

### Impact Classification Flow

```mermaid
graph TD
    Start([Git Diff Analysis]) --> CheckUnstaged{Unstaged<br/>Changes?}
    
    CheckUnstaged -->|Yes| AutoStage[Auto-stage Changes]
    CheckUnstaged -->|No| AnalyzeChanges[Analyze Staged Changes]
    AutoStage --> AnalyzeChanges
    
    AnalyzeChanges --> ClassifyFiles{Classify File Types}
    
    ClassifyFiles --> CodeFiles[Code Files<br/>.js, .ts, .py, .sh]
    ClassifyFiles --> TestFiles[Test Files<br/>test/, spec/, .test.]
    ClassifyFiles --> DocFiles[Doc Files<br/>.md, docs/]
    ClassifyFiles --> DepFiles[Dependency Files<br/>package.json, etc]
    
    CodeFiles --> CountCode[Count Code Changes]
    TestFiles --> CountTests[Count Test Changes]
    DocFiles --> CountDocs[Count Doc Changes]
    DepFiles --> FlagDeps[Flag Dep Changes]
    
    CountCode --> Calculate[Calculate Impact Score]
    CountTests --> Calculate
    CountDocs --> Calculate
    FlagDeps --> Calculate
    
    Calculate --> DetermineImpact{Impact Level?}
    
    DetermineImpact -->|Score > 50| HighImpact[HIGH Impact<br/>All steps run]
    DetermineImpact -->|20 < Score ≤ 50| MediumImpact[MEDIUM Impact<br/>Most steps run]
    DetermineImpact -->|Score ≤ 20| LowImpact[LOW Impact<br/>Many steps skipped]
    
    HighImpact --> Report[Generate Impact Report]
    MediumImpact --> Report
    LowImpact --> Report
    
    Report --> End([Impact Analysis Complete])
    
    style Start fill:#90EE90
    style End fill:#87CEEB
    style HighImpact fill:#FFB6C1
    style MediumImpact fill:#FFE4B5
    style LowImpact fill:#90EE90
```

### Impact Score Calculation

```mermaid
graph LR
    Inputs[File Changes] --> Score{Impact Score}
    
    Score --> Code[Code Changes<br/>× 3 weight]
    Score --> Tests[Test Changes<br/>× 2 weight]
    Score --> Docs[Doc Changes<br/>× 1 weight]
    Score --> Deps[Dep Changes<br/>+20 bonus]
    
    Code --> Total[Total Score]
    Tests --> Total
    Docs --> Total
    Deps --> Total
    
    Total --> Decision{Threshold}
    Decision -->|> 50| High[HIGH]
    Decision -->|20-50| Medium[MEDIUM]
    Decision -->|< 20| Low[LOW]
    
    style High fill:#FFB6C1
    style Medium fill:#FFE4B5
    style Low fill:#90EE90
```

---

## Smart Execution Decision Tree

### Step Skip Logic

```mermaid
graph TD
    Start([Smart Execution Enabled]) --> ImpactLevel{Change<br/>Impact?}
    
    ImpactLevel -->|HIGH| HighPath[Run All Steps<br/>0-14]
    ImpactLevel -->|MEDIUM| MediumPath[Skip Some Steps]
    ImpactLevel -->|LOW| LowPath[Skip Many Steps]
    
    %% Medium impact decisions
    MediumPath --> HasCode{Code<br/>Changes?}
    HasCode -->|Yes| RunCodeSteps[Run: 0,1,2,3,4,5,6,7,9,10,11,12,13,14]
    HasCode -->|No| SkipCodeSteps[Skip: 9]
    
    RunCodeSteps --> HasDeps{Dep<br/>Changes?}
    SkipCodeSteps --> HasDeps
    
    HasDeps -->|Yes| RunDepStep[Run: 8]
    HasDeps -->|No| SkipDepStep[Skip: 8]
    
    RunDepStep --> MediumEnd[Medium Path Complete]
    SkipDepStep --> MediumEnd
    
    %% Low impact decisions
    LowPath --> OnlyDocs{Only Doc<br/>Changes?}
    OnlyDocs -->|Yes| DocOnlyPath[Run: 0,1,2,12,13,14<br/>Skip: 3,4,5,6,7,8,9,10,11]
    OnlyDocs -->|No| MinimalPath[Run: 0,1,2,10,11<br/>Skip: 3,4,5,6,7,8,9,12,13,14]
    
    DocOnlyPath --> LowEnd[Low Path Complete]
    MinimalPath --> LowEnd
    
    %% Completion
    HighPath --> Execute[Execute Selected Steps]
    MediumEnd --> Execute
    LowEnd --> Execute
    
    Execute --> SaveReport[Save Skip Report]
    SaveReport --> End([Smart Execution Complete])
    
    style Start fill:#90EE90
    style End fill:#87CEEB
    style HighPath fill:#FFB6C1
    style DocOnlyPath fill:#90EE90
    style Execute fill:#E6E6FA
```

### Skip Rules by Change Type

```mermaid
graph TD
    ChangeType[Change Type Detection] --> DocOnly{Documentation<br/>Only?}
    
    DocOnly -->|Yes| SkipTests[Skip Steps:<br/>5,6,7 - Testing]
    DocOnly -->|Yes| SkipCode[Skip Step:<br/>9 - Code Quality]
    DocOnly -->|Yes| SkipDeps[Skip Step:<br/>8 - Dependencies]
    DocOnly -->|Yes| SkipScripts[Skip Step:<br/>3 - Script Refs]
    DocOnly -->|Yes| SkipDir[Skip Step:<br/>4 - Directory]
    DocOnly -->|Yes| SkipContext[Skip Step:<br/>10 - Context]
    
    SkipTests --> DocSteps[Run Steps:<br/>0,1,2,11,12,13,14]
    SkipCode --> DocSteps
    SkipDeps --> DocSteps
    SkipScripts --> DocSteps
    SkipDir --> DocSteps
    SkipContext --> DocSteps
    
    DocOnly -->|No| CheckCode{Code<br/>Changes?}
    
    CheckCode -->|Yes| FullExec[Run All Steps<br/>0-14]
    CheckCode -->|No| PartialExec[Selective Execution]
    
    DocSteps --> TimeSaving[Time Savings:<br/>85% faster]
    FullExec --> Baseline[Baseline:<br/>23 minutes]
    PartialExec --> MiddleSaving[Time Savings:<br/>40-60% faster]
    
    style DocOnly fill:#E6E6FA
    style FullExec fill:#FFB6C1
    style TimeSaving fill:#90EE90
```

---

## AI Cache Flow

### Cache Lookup and Storage

```mermaid
graph TD
    Start([AI Call Initiated]) --> GenerateKey[Generate Cache Key<br/>SHA256 of Prompt]
    
    GenerateKey --> CheckCache{Cache<br/>Entry Exists?}
    
    CheckCache -->|Yes| CheckTTL{Entry<br/>Fresh?}
    CheckCache -->|No| MissPath[Cache Miss]
    
    CheckTTL -->|Yes, < 24h| CacheHit[Cache Hit<br/>Load Response]
    CheckTTL -->|No, > 24h| Expired[Cache Expired]
    
    CacheHit --> IncrementHits[Increment Hit Counter]
    IncrementHits --> UseCache[Use Cached Response]
    UseCache --> LogHit[Log: Cache Hit]
    LogHit --> End([Return Response])
    
    Expired --> RemoveExpired[Remove Expired Entry]
    RemoveExpired --> MissPath
    
    MissPath --> CallAI[Call GitHub Copilot CLI]
    CallAI --> ReceiveResponse[Receive AI Response]
    ReceiveResponse --> StoreCache[Store in Cache]
    StoreCache --> SetTTL[Set TTL: 24 hours]
    SetTTL --> UpdateIndex[Update Cache Index]
    UpdateIndex --> LogMiss[Log: Cache Miss]
    LogMiss --> End
    
    style Start fill:#90EE90
    style CacheHit fill:#90EE90
    style MissPath fill:#FFE4B5
    style End fill:#87CEEB
    style UseCache fill:#E6E6FA
```

### Cache Maintenance

```mermaid
graph TD
    Start([Cache Maintenance<br/>Every 24h]) --> LoadIndex[Load Cache Index]
    
    LoadIndex --> CheckSize{Cache Size<br/>> 100 MB?}
    
    CheckSize -->|Yes| SizeCleanup[Size-based Cleanup]
    CheckSize -->|No| CheckCount{Entry Count<br/>> 1000?}
    
    SizeCleanup --> RemoveLRU[Remove LRU Entries]
    RemoveLRU --> UpdateIndex1[Update Index]
    
    CheckCount -->|Yes| CountCleanup[Count-based Cleanup]
    CheckCount -->|No| TTLCheck[TTL Check]
    
    CountCleanup --> RemoveOldest[Remove Oldest Entries]
    RemoveOldest --> UpdateIndex2[Update Index]
    
    TTLCheck --> ScanEntries[Scan All Entries]
    ScanEntries --> CheckExpired{Entry<br/>Expired?}
    
    CheckExpired -->|Yes| RemoveEntry[Remove Entry]
    CheckExpired -->|No| KeepEntry[Keep Entry]
    
    RemoveEntry --> NextEntry{More<br/>Entries?}
    KeepEntry --> NextEntry
    
    NextEntry -->|Yes| CheckExpired
    NextEntry -->|No| FinalUpdate[Final Index Update]
    
    UpdateIndex1 --> FinalUpdate
    UpdateIndex2 --> FinalUpdate
    
    FinalUpdate --> LogStats[Log Statistics]
    LogStats --> End([Maintenance Complete])
    
    style Start fill:#90EE90
    style End fill:#87CEEB
    style RemoveLRU fill:#FFB6C1
    style RemoveOldest fill:#FFB6C1
    style RemoveEntry fill:#FFB6C1
```

**Cache Benefits**:
- 60-80% token usage reduction
- Faster execution for repeated operations
- Automatic TTL management (24 hours)
- Automatic cleanup and maintenance

---

## Checkpoint Resume Logic

### Checkpoint Creation and Resume

```mermaid
graph TD
    Start([Workflow Execution]) --> CheckExisting{Checkpoint<br/>File Exists?}
    
    CheckExisting -->|Yes| CheckFlag{--no-resume<br/>flag?}
    CheckExisting -->|No| FreshStart[Start from Step 0]
    
    CheckFlag -->|Yes| IgnoreCheckpoint[Ignore Checkpoint<br/>Fresh Start]
    CheckFlag -->|No| LoadCheckpoint[Load Checkpoint]
    
    IgnoreCheckpoint --> FreshStart
    
    LoadCheckpoint --> ParseCheckpoint[Parse Checkpoint Data]
    ParseCheckpoint --> ValidateCheckpoint{Valid<br/>Checkpoint?}
    
    ValidateCheckpoint -->|Yes| ResumeStep[Resume from Step N]
    ValidateCheckpoint -->|No| CheckpointError[Checkpoint Error]
    
    CheckpointError --> FreshStart
    
    FreshStart --> ExecuteStep[Execute Step]
    ResumeStep --> ExecuteStep
    
    ExecuteStep --> StepComplete{Step<br/>Complete?}
    
    StepComplete -->|Success| SaveCheckpoint[Save Checkpoint]
    StepComplete -->|Failure| HandleError[Handle Error]
    
    SaveCheckpoint --> MoreSteps{More<br/>Steps?}
    
    MoreSteps -->|Yes| NextStep[Next Step]
    MoreSteps -->|No| Complete[Workflow Complete]
    
    NextStep --> ExecuteStep
    
    HandleError --> SaveFailureCheckpoint[Save Failure State]
    SaveFailureCheckpoint --> Exit[Exit with Error]
    
    Complete --> DeleteCheckpoint[Delete Checkpoint]
    DeleteCheckpoint --> End([Workflow Complete])
    
    style Start fill:#90EE90
    style End fill:#87CEEB
    style ResumeStep fill:#E6E6FA
    style SaveCheckpoint fill:#FFE4B5
    style HandleError fill:#FFB6C1
```

### Checkpoint File Structure

```mermaid
graph LR
    Checkpoint[Checkpoint File] --> LastStep[LAST_COMPLETED_STEP=N]
    Checkpoint --> NextStep[NEXT_STEP=N+1]
    Checkpoint --> Timestamp[WORKFLOW_START_TIME]
    Checkpoint --> BacklogDir[BACKLOG_DIR]
    Checkpoint --> SummaryDir[SUMMARY_DIR]
    Checkpoint --> LogDir[LOG_DIR]
    Checkpoint --> Flags[Execution Flags]
    
    Flags --> Smart[SMART_EXECUTION]
    Flags --> Parallel[PARALLEL_EXECUTION]
    Flags --> Auto[AUTO_COMMIT]
    
    style Checkpoint fill:#E6E6FA
    style LastStep fill:#FFE4B5
    style NextStep fill:#90EE90
```

---

## Module Architecture

### Core Module Relationships

```mermaid
graph TD
    Main[execute_tests_docs_workflow.sh] --> Orchestration[Orchestration Layer]
    Main --> Library[Library Layer]
    
    Orchestration --> PreFlight[pre_flight.sh]
    Orchestration --> Validation[validation_orchestrator.sh]
    Orchestration --> Quality[quality_orchestrator.sh]
    Orchestration --> Finalization[finalization_orchestrator.sh]
    
    Library --> AI[AI Integration]
    Library --> Change[Change Management]
    Library --> Metrics[Metrics & Performance]
    Library --> Config[Configuration]
    Library --> Utils[Utilities]
    
    AI --> AIHelpers[ai_helpers.sh]
    AI --> AICache[ai_cache.sh]
    AI --> AIPersonas[ai_personas.sh]
    AI --> AIPrompt[ai_prompt_builder.sh]
    AI --> AIValidation[ai_validation.sh]
    
    Change --> ChangeDetect[change_detection.sh]
    Change --> GitCache[git_cache.sh]
    Change --> DependencyGraph[dependency_graph.sh]
    
    Metrics --> MetricsCore[metrics.sh]
    Metrics --> MetricsValidation[metrics_validation.sh]
    Metrics --> Performance[performance.sh]
    
    Config --> ConfigCore[config.sh]
    Config --> ConfigWizard[config_wizard.sh]
    Config --> TechStack[tech_stack.sh]
    Config --> ProjectKind[project_kind_config.sh]
    
    Utils --> FileOps[file_operations.sh]
    Utils --> EditOps[edit_operations.sh]
    Utils --> UtilsCore[utils.sh]
    Utils --> Colors[colors.sh]
    
    style Main fill:#90EE90
    style Orchestration fill:#E6E6FA
    style Library fill:#FFE4B5
    style AI fill:#B0E0E6
    style Change fill:#FFB6C1
    style Metrics fill:#F0E68C
    style Config fill:#DDA0DD
    style Utils fill:#F5DEB3
```

### Step Execution Flow

```mermaid
graph TD
    Start([Step Execution]) --> Load[Load Step Module]
    
    Load --> PreValidate[Pre-Validation]
    PreValidate --> CheckSkip{Skip Step?}
    
    CheckSkip -->|Yes| SkipLog[Log Skip Reason]
    CheckSkip -->|No| StartTimer[Start Step Timer]
    
    SkipLog --> SkipEnd[Mark as Skipped]
    SkipEnd --> NextDecision{More<br/>Steps?}
    
    StartTimer --> LoadPersona[Load AI Persona]
    LoadPersona --> ExecuteLogic[Execute Step Logic]
    
    ExecuteLogic --> AICall{Needs<br/>AI?}
    
    AICall -->|Yes| CheckAICache[Check AI Cache]
    AICall -->|No| DirectExecution[Direct Execution]
    
    CheckAICache --> CacheHit{Cache<br/>Hit?}
    
    CacheHit -->|Yes| UseCache[Use Cached Response]
    CacheHit -->|No| CallAI[Call AI Persona]
    
    CallAI --> StoreCache[Store in Cache]
    StoreCache --> ProcessAI[Process AI Response]
    
    UseCache --> ProcessAI
    ProcessAI --> Validate[Validate Output]
    
    DirectExecution --> Validate
    
    Validate --> ValidationOK{Validation<br/>Pass?}
    
    ValidationOK -->|Yes| StopTimer[Stop Step Timer]
    ValidationOK -->|No| HandleFailure[Handle Failure]
    
    StopTimer --> SaveReport[Save Step Report]
    SaveReport --> UpdateMetrics[Update Metrics]
    UpdateMetrics --> SaveCheckpoint[Save Checkpoint]
    SaveCheckpoint --> Success[Mark as Success]
    
    HandleFailure --> LogError[Log Error]
    LogError --> SaveFailure[Save Failure Report]
    SaveFailure --> UpdateFailMetrics[Update Failure Metrics]
    UpdateFailMetrics --> FailCheckpoint[Save Failure Checkpoint]
    FailCheckpoint --> Failure[Mark as Failed]
    
    Success --> NextDecision
    Failure --> NextDecision
    
    NextDecision -->|Yes| NextStep[Load Next Step]
    NextDecision -->|No| Complete[Workflow Complete]
    
    NextStep --> Load
    Complete --> End([End])
    
    style Start fill:#90EE90
    style End fill:#87CEEB
    style Success fill:#90EE90
    style Failure fill:#FFB6C1
    style UseCache fill:#E6E6FA
```

### AI Persona Assignment

```mermaid
graph TD
    Step[Workflow Step] --> AssignPersona{Assign AI Persona}
    
    AssignPersona -->|Step 0| PreAnalyst[pre_analyst]
    AssignPersona -->|Step 1| DocSpecialist[documentation_specialist]
    AssignPersona -->|Step 2| ConsistencyAnalyst[consistency_analyst]
    AssignPersona -->|Step 3| ScriptValidator[script_validator]
    AssignPersona -->|Step 4| DirectoryValidator[directory_validator]
    AssignPersona -->|Step 5| TestReviewer[test_engineer - review]
    AssignPersona -->|Step 6| TestGenerator[test_engineer - generation]
    AssignPersona -->|Step 7| TestExecutor[test_execution_analyst]
    AssignPersona -->|Step 8| DepAnalyst[dependency_analyst]
    AssignPersona -->|Step 9| CodeReviewer[code_reviewer]
    AssignPersona -->|Step 10| ContextAnalyst[context_analyst]
    AssignPersona -->|Step 11| GitSpecialist[git_specialist]
    AssignPersona -->|Step 12| MarkdownLinter[markdown_linter]
    AssignPersona -->|Step 13| PromptEngineer[prompt_engineer]
    AssignPersona -->|Step 14| UXDesigner[ux_designer]
    
    PreAnalyst --> LoadPrompt[Load Prompt Template]
    DocSpecialist --> LoadPrompt
    ConsistencyAnalyst --> LoadPrompt
    ScriptValidator --> LoadPrompt
    DirectoryValidator --> LoadPrompt
    TestReviewer --> LoadPrompt
    TestGenerator --> LoadPrompt
    TestExecutor --> LoadPrompt
    DepAnalyst --> LoadPrompt
    CodeReviewer --> LoadPrompt
    ContextAnalyst --> LoadPrompt
    GitSpecialist --> LoadPrompt
    MarkdownLinter --> LoadPrompt
    PromptEngineer --> LoadPrompt
    UXDesigner --> LoadPrompt
    
    LoadPrompt --> ProjectKind{Project<br/>Kind?}
    
    ProjectKind --> CustomizePrompt[Customize Prompt]
    CustomizePrompt --> BuildPrompt[Build Final Prompt]
    BuildPrompt --> CallAI[Call GitHub Copilot CLI]
    
    style Step fill:#90EE90
    style CallAI fill:#87CEEB
    style DocSpecialist fill:#E6E6FA
    style TestGenerator fill:#FFE4B5
    style UXDesigner fill:#FFB6C1
```

---

## Performance Comparison

### Execution Time by Mode

```mermaid
graph TD
    Baseline[Baseline Execution<br/>Sequential, No Cache<br/>~23 minutes]
    
    Baseline --> SmartOnly[+ Smart Execution<br/>Change-based Skipping]
    Baseline --> ParallelOnly[+ Parallel Execution<br/>3-Track Parallelization]
    Baseline --> CacheOnly[+ AI Caching<br/>Response Reuse]
    
    SmartOnly --> SmartTime[Documentation: 3.5 min 85% faster<br/>Code: 14 min 40% faster<br/>Full: 23 min baseline]
    
    ParallelOnly --> ParallelTime[All Changes: 15.5 min<br/>33% faster]
    
    CacheOnly --> CacheTime[Repeated Ops: Variable<br/>60-80% token reduction]
    
    SmartOnly --> Combined[Combined Mode]
    ParallelOnly --> Combined
    CacheOnly --> Combined
    
    Combined --> OptimalTime[Documentation: 2.3 min 90% faster<br/>Code: 10 min 57% faster<br/>Full: 15.5 min 33% faster]
    
    style Baseline fill:#FFB6C1
    style SmartTime fill:#FFE4B5
    style ParallelTime fill:#FFE4B5
    style CacheTime fill:#FFE4B5
    style OptimalTime fill:#90EE90
```

---

## Technology Stack Detection

### Detection Flow

```mermaid
graph TD
    Start([Project Analysis]) --> CheckConfig{.workflow-config.yaml<br/>exists?}
    
    CheckConfig -->|Yes| LoadConfig[Load Configuration]
    CheckConfig -->|No| AutoDetect[Auto-Detection]
    
    LoadConfig --> ProjectKind{project.kind<br/>specified?}
    
    ProjectKind -->|Yes| UseSpecified[Use Specified Kind]
    ProjectKind -->|No| AutoDetect
    
    AutoDetect --> ScanFiles[Scan Project Files]
    
    ScanFiles --> CheckPackage{package.json<br/>exists?}
    ScanFiles --> CheckPython{Python files?}
    ScanFiles --> CheckShell{Shell scripts?}
    ScanFiles --> CheckStatic{HTML/CSS?}
    
    CheckPackage -->|Yes| AnalyzePackage[Analyze Dependencies]
    CheckPython -->|Yes| PythonKind[Python Project]
    CheckShell -->|Yes| ShellKind[Shell Automation]
    CheckStatic -->|Yes| StaticKind[Static Website]
    
    AnalyzePackage --> HasReact{React<br/>dependency?}
    AnalyzePackage --> HasVue{Vue<br/>dependency?}
    AnalyzePackage --> HasExpress{Express<br/>dependency?}
    
    HasReact -->|Yes| ReactKind[React SPA]
    HasVue -->|Yes| VueKind[Vue SPA]
    HasExpress -->|Yes| NodeAPIKind[Node.js API]
    
    HasReact -->|No| NodeGeneric[Node.js Generic]
    HasVue -->|No| NodeGeneric
    HasExpress -->|No| NodeGeneric
    
    UseSpecified --> ApplyConfig[Apply Configuration]
    ReactKind --> ApplyConfig
    VueKind --> ApplyConfig
    NodeAPIKind --> ApplyConfig
    NodeGeneric --> ApplyConfig
    PythonKind --> ApplyConfig
    ShellKind --> ApplyConfig
    StaticKind --> ApplyConfig
    
    ApplyConfig --> TestFramework[Detect Test Framework]
    TestFramework --> BuildSystem[Detect Build System]
    BuildSystem --> SetDefaults[Set Quality Standards]
    SetDefaults --> SaveConfig[Save Configuration]
    SaveConfig --> End([Tech Stack Configured])
    
    style Start fill:#90EE90
    style End fill:#87CEEB
    style AutoDetect fill:#FFE4B5
    style ApplyConfig fill:#E6E6FA
```

---

## Summary

These diagrams visualize the complex workflows and decision logic in the AI Workflow Automation system:

1. **15-Step Workflow Flow**: Shows the complete sequential execution path
2. **Dependency Relationships**: Illustrates which steps depend on others
3. **Parallel Execution Groups**: Demonstrates 3-track parallelization strategy
4. **Change Detection Logic**: Explains impact classification algorithm
5. **Smart Execution Decision Tree**: Shows step skip logic based on changes
6. **AI Cache Flow**: Visualizes cache lookup, storage, and maintenance
7. **Checkpoint Resume Logic**: Demonstrates automatic workflow continuation
8. **Module Architecture**: Shows the modular structure and relationships

### Quick Reference

| Diagram | Use Case | Key Insight |
|---------|----------|-------------|
| Workflow Flow | Understanding execution order | Sequential: 26 min, Parallel: 15.5 min |
| Dependencies | Identifying critical path | Bottleneck: Step 7 (Test Execution, 240s) |
| Parallel Groups | Optimization opportunities | 33% time savings with 3-track execution |
| Change Detection | Smart execution decisions | 85% faster for documentation-only changes |
| AI Cache | Performance optimization | 60-80% token reduction, 24-hour TTL |
| Checkpoints | Reliability & resume | Automatic continuation from last step |

### Related Documentation

- **Performance Benchmarks**: [PERFORMANCE_BENCHMARKS.md](performance-benchmarks.md)
- **Smart Execution Guide**: [SMART_EXECUTION_GUIDE.md](smart-execution.md)
- **Parallel Execution Guide**: [PARALLEL_EXECUTION_GUIDE.md](parallel-execution.md)
- **AI Cache Configuration**: [AI_CACHE_CONFIGURATION_GUIDE.md](ai-cache-configuration.md)
- **Checkpoint Management**: [CHECKPOINT_MANAGEMENT_GUIDE.md](checkpoint-management.md)
- **Configuration Schema**: [CONFIGURATION_SCHEMA.md](configuration.md)

---

**Document Version**: 2.4.0  
**Last Updated**: 2025-12-23  
**Maintained By**: AI Workflow Automation Team
