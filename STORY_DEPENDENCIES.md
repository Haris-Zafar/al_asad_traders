# Story dependencies

`A --> B`: story B cannot be built before story A. Direct dependencies only. Stories: `wholesale_project.md`.

```mermaid
flowchart TD
  subgraph LS[Login and sync]
    S32["S32 Login"]; S33["S33 Device setup"]; S34["S34 Sync state"]; S35["S35 Logout"]
  end
  subgraph PR[Products]
    S1["S1 Add product"]; S2["S2 Scan barcode"]; S3["S3 Tags"]; S4["S4 Archive product"]
  end
  subgraph PC[Prices]
    S5["S5 Buyer/supplier rates"]; S6["S6 Retail price"]; S7["S7 Auto price"]; S8["S8 Override price"]
  end
  subgraph PA[People and accounts]
    S9["S9 Buyers/suppliers"]; S10["S10 Bank accounts"]; S11["S11 Profile"]
  end
  subgraph DM[Demands]
    S12["S12 Record demand"]; S13["S13 Item status"]; S14["S14 Edit demand items"]
  end
  subgraph PL[Purchase lists]
    S15["S15 Create list"]; S16["S16 Send to list"]; S17["S17 Share item"]; S18["S18 Direct list items"]; S19["S19 Rate paid, purchased"]
  end
  subgraph BL[Billing]
    S20["S20 Demand to bill"]; S21["S21 Edit billed qty"]; S22["S22 Direct bill items"]; S23["S23 Draft bill"]
    S24["S24 Issue bill"]; S25["S25 Cleared"]; S26["S26 Move to ledger"]; S27["S27 Bill notes"]
  end
  subgraph LD[Ledger]
    S28["S28 Ledger and balance"]; S29["S29 Cash, bank, opening"]; S30["S30 Return"]; S31["S31 Correction"]
  end
  S32 --> S33 & S1 & S9 & S11
  S33 --> S34 & S24
  S34 --> S35
  S1 --> S2 & S3 & S4 & S5 & S6 & S12 & S18
  S9 --> S5 & S10 & S12 & S15 & S28
  S11 --> S10
  S5 & S6 --> S7
  S7 --> S19 & S23
  S12 --> S14 & S16 & S20
  S15 --> S16 & S18
  S16 --> S13 & S17
  S18 --> S19
  S20 --> S13 & S21
  S23 --> S8 & S20 & S22 & S24 & S27
  S24 --> S25 & S26
  S28 --> S26 & S29
  S10 --> S29
  S29 --> S30 & S31
```

## Build order

Stories on the same line can be built in parallel.

1. S32
2. S33, S1, S9, S11
3. S34, S2, S3, S4, S5, S6, S10, S12, S15, S28
4. S35, S7, S14, S16, S18, S29
5. S17, S19, S23, S30, S31
6. S8, S20, S22, S24, S27
7. S13, S21, S25, S26
