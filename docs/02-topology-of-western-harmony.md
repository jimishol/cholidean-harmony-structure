# **Abstract**

This document demonstrates how **Umbilic-Surface Harmony Grammar** decodes standard diatonic progressions into explicit 3D spatial operations. We define tonal motion in two distinct states:

**Passive Circulation (s=1, r=0):** Unrotated movement along the circle of fourths, generating pre-dominant chains and emergent 7th chords via local object coherence.

**Active Closure (r=P):** Triangle rotation, which breaks the diatonic loop to create dominant function and structural cadence.

By analyzing the topology of the Major Scale, we identify a "Singularity Triangle" (the D-triangle in C Major) which contains only one scale tone. This geometric asymmetry explains the unique pivoting role of the supertonic (ii) and sets the stage for analyzing complex modal and chromatic exceptions.

> **Note on Stylistic Scope: The Classical Filter**
>
> The Umbilic-Surface Grammar describes the raw topology of the 12-tone system. Like a coordinate system, it is neutral; it does not mandate a specific musical style.
>
> However, to demonstrate the grammar's predictive power, this document applies a specific **"Classical Filter"** (Western Common Practice, c. 1600–1900). Under this interpretation:
> *   **Objects:** We prioritize Triads (`M`, `m`) over single tones or raw dyads.
> *   **Function:** We interpret Geometric Instability (Active Diagonals) as "Dominant Tension" requiring resolution.
> *   **Selection:** We interpret the neutral Generator state (0T) as implying the root of the full Major Triad (M).
>
> Readers should note that other musical traditions (Modal Jazz, Rock, Impressionism) utilize the same geometric lattice but may employ different interpretive rules—valuing static loops over closure, or treating "Active" surfaces as stable colors rather than tensions.

---

## **1. Example — C Major / A Minor Circle-of-Fifths Traversal**

```text
# Starting surface: G-surface (no F#)
M       >   m       >   0M       >   m       >   0M       >   m
Gmaj     >   Em     >   Cmaj     >   Am      >   Fmaj     >   Dm
```

**Surface mapping:**

| Token | Destination Surface | Object | Notes (C major scale) |
| ----- | ------------------- | ------ | --------------------- |
| M     | G-surface           | M      | G–B–D                 |
| m     | C-surface           | m      | E–G–B                 |
| 0M    | C-surface           | M      | C–E–G                 |
| m     | F-surface           | m      | A–C–E                 |
| 0M    | F-surface           | M      | F–A–C                 |
| m     | Bb-surface          | m      | D–F–A                 |

**Key points:**

1. **Surface adherence:** Each chord is read only from the allowed notes of its surface.
2. **Pre-dominant circulation:** Only `s=1, r=0` is used — no rotation yet.
3. **Cohered subsets produce sevenths naturally:**
   * `m0M` on C-surface → E–G–B + C–E–G → **Cmaj7**

**To reach dominant closure:**

```text
PM  >  M
```

* `PM` = rotated triangle (r = P) on the V surface → dominant function
* `M`  = tonic surface read after rotation → tonic chord
* This formalizes cadence under the grammar

---

## **2. Surface Activity and Rotation Eligibility**

While the grammar formally permits rotation (`r ≠ 0`) at any step, functional harmony is constrained by the internal geometry of the sounding surface.

Because Augmented-Triad Triangles are **directed**, a Major7 surface is internally asymmetric. It possesses two distinct geometric borders that define the available axes of rotation:

1.  **The Upper "Stable" Border (`c`):** The Root-Fifth axis. This is the axis of **S-Rotation**. It represents the "Long Cycle" of the lattice, as moving 4 stations forward (`s=4`) is topologically equivalent to one S-rotation (`r=S`).
2.  **The Lower "Pivoting" Border:** The axis of **P-Rotation**. This cuts across the lattice grain, allowing immediate modulation.

We define the tension of the e borders along the longitudinal flow (s=1) through **Activity States**.

### **2.1 Activity Classes**
Activity is a measure of "Longitudinal Pressure"—the urge of the surface to move forward along the Circle of Fourths (`s=1`) versus its ability to rotate.

*   **Active:** The surface sounds a **diagonal dyad** (`d` or `l`).
    *   *Musical implication:* High directional energy; demands resolution.
*   **Semi-Active:** The surface sounds a saturated **augmented-triad edge** (`e`).
    *   *Musical implication:* Structural locking; the surface is "anchored" to its triangle.
*   **Inactive:** Neither a diagonal nor an edge is fully present.
    *   *Musical implication:* Tonal ambiguity.

### **2.2 The Law of P-Rotational Admissibility (The Blocking Rule)**

While **S-Rotations** (Snaps) are always admissible—as they function as the "Strong Force" of cadence capable of overriding surface inertia—**P-Rotations** are constrained by the internal geometry of the sounding surface.

**P-Rotation** operates across the **Augmented-Triad Edge (`e`)**. The sounding content determines if this border is passable.

1.  **Saturated Border:** If the `e` dyad of a surface is present (e.g., G–B on the G-surface), the border is **rigid**.
    *   **Rule:** **P-Rotation is Functionally Blocked.**
    *   **Result:** The chord cannot "twist" into the relative major/minor via this axis. It must follow gravity (`s=1`) or execute a forceful Snap (`S`).
2.  **Unsaturated Border:** If the `e` dyad is incomplete or absent (e.g., D–F on the Bb-surface, missing Bb), the border is **fluid**.
    *   **Rule:** **P-Rotation is Admissible.**
    *   **Result:** The surface may pivot (`r=P`) to a new triangle orientation.

> **Note on Directionality:** This rule applies strictly to the **current state**. If the edge is saturated *now*, the rotation is blocked. We do not need to calculate inverse paths; the local geometry dictates the available vectors.

---

## **3. The Pivot Principle (Common-Tone Constraint)**

When a rotation is admissible, the geometry dictates a strict voice-leading constraint.

**Proposition:** On any admissible **P-rotation**, exactly **one pitch class** is preserved between the pre-rotation and post-rotation surfaces.

This geometric singularity explains the mechanics of the standard cadence:
 *   **ii → V (Dm → G):**
     *   **ii (on Bb'):** The `e` edge (Bb-D) is unsaturated (Bb is missing). **Rotation is Admissible.**
     *   **Pivot:** Surface (D-Bb-F-A) and Surface (G-B-F#-D) overlap at exactly one point. The only common pitch class between the **Bb-Surface notes** and the **G-Surface notes** is **D**.
     *   *Result:* The chord pivots on D, twisting into the dominant.
*   **V → I (G → C):**
    *   **V (on G'):** The `e` edge (G-B) is saturated. **Rotation is Blocked.**
    *   *Result:* The chord cannot twist. It must "fall" (`s=1`) to C.

---

## **4. Scale Establishment: The Two-Pole Theorem**

A diatonic key is a topological space bounded by two geometric limits: the **Subdominant Pole** (Bb') and the **Dominant Pole** (G').

**Definition:** A Key is **Fully Established** when the geometry of both Poles is implied or declared.

### **4.1 Activity States**
*   **Active (Directional):** A surface is **Active** if its **Diagonal (`d`)** or **Leading Dyad (`l`)** is sounded. These intervals create a demand for resolution.
*   **Semi-Active (Locked):** A surface is **Semi-Active** if **ANY Augmented Edge** contained within its notes is saturated.
    *   **The "Or" Rule:** A surface is locked if its **Generator Edge** is saturated **OR** if its **Opposite Edge** (the edge of the backward neighbor) is saturated.
    *   *Example:* On the **F-Surface** (F-A-C-E), the Generator Edge is **F-A** and the Opposite Edge is **C-E**. Sounding *either* pair locks the surface.
    *   *Remote Locking:* Saturated edges also lock their native surfaces remotely. For instance, sounding **C-E** locks the **C-Surface** regardless of where the cursor is currently located.

### **4.2 Establishment Scenarios**

*   **The Strongest Establishment (`ii > V > I`):**
    *   **`ii` (D-F-A):** Activates **Bb'** (via diagonal F-D) and semi-activates **F'** (via edge A-F).
    *   **`V` (G-B-D):** Activates **G'** (via diagonal B-D) and semi-activates **C'** (via edge B-G).
    *   **Result:** The progression spans the full width of the C Major Key (from Deep Flat to Sharp). The key is unmistakable.

*   **The Gravitational Establishment (`IV > V > I`):**
    *   **`IV` (F-A-C):** Locks **F'** (via Generator Edge F-A) and semi-activates **Bb'** (via edge A-F).
    *   **`V` (G-B-D):** Activates **G'** and semi-activates **C'** (via edge B-G).
    *   **Result:** The Left Pole is established via the neighbor surface.

*   **The Ambiguous Establishment (`vi > V > I`):**
    *   **`vi` (A-C-E):**
        *   Activates **F'** (via diagonal A-C).
        *   **Locks F'** (via Opposite Edge C-E).
        *   **Locks C'** (via Remote Locking of C-E).
    *   **`V` (G-B-D):** Activates **G'**.
    *   **The Problem:** While the chords are stable, the Deep Left Pole (Bb') is never touched.
    *   **Result:** The ear cannot distinguish if this is **C Major** (`vi > V`) or **G Major** (`ii > I`). Because the defining geometry of the C-Natural Subdominant Bb') is absent, the tonality remains floating between the two keys.

---

# **5. Application: The Standard Cadence (ii–V–I)**

We can now parse the most common progression in Western music as a sequence that systematically activates the Two Poles defined above.

To visualize the hidden geometry, we use the **"Skeleton Melody" (F -> D -> B -> C)**. This tracer highlights the **Active Diagonals** that the chords utilize.

**Sequence:** `Dm (ii) → G (V) → C (I)`

| Step | Chord | Surface | Skeleton Note | Geometric Action |
| :--- | :--- | :--- | :--- | :--- |
| **1** | **Dm** | **Bb'** | **F** | **Activate Left Pole.**<br>The chord `m` (D-F-A) sounds the **Diagonal `d`** (F-D) of the Bb-Surface. It also semi-activates F-surface. The skeleton note **F** highlights this semi-active state. |
| **2** | **G** | **G'** | **B** | **Activate Right Pole.**<br>The chord `M` (G-B-D) sounds the **Diagonal `d`** (B-D) of the G-Surface. The skeleton note **B** highlights this active state.<br>**The Pivot:** The transition relies on the geometric singularity **D**, which is the only common tone between the active Bb' and G' surfaces. |
| **3** | **C** | **C'** | **C** | **Resolution.**<br>The tension resolves to the geometric center. The arrival of the **C-E** dyad locks the F' surface (Semi-Active), preventing forward rotation. |

## **6. Minor and Modal Systems: The S-Rotation (Stable/Snap)**

While the Major scale relies on a fixed geometry where gravity (`s=1`) and resolution coincide, the Minor system reveals the distinct mechanical layers of tonality. Specifically, it exposes the **S-Rotation** as the universal operator of cadence.

### **6.1 Etymology: Stable vs. Snap**
> The term **S** derives from **"Stable,"** reflecting the retention of the pitch axis during the rotation.
> *   **The Mechanism (Stable):** An **S-rotation** (`0S`) preserves the **pitch classes** of the Curve dyad (`c`)—the Root and Fifth.
>     *   *Example:* Rotating C-Surface (`C-E-G-B`) to Ab-Surface (`Ab-C-Eb-G`).
>     *   The notes **C** and **G** are retained.
>     *   *Transformation:* They shift from being the **Generator/5th** of the old surface to becoming the **3rd/7th** (the low border) of the new surface.
> *   **The Effect (Snap):** Because these pillars hold while the internal diagonal shifts (E becomes Eb), the ear perceives a sudden "Snap" of the mode (e.g., C Major collapsing to C Minor).

### **6.2 The Cycle of Navigation and Closure**
All tonal journeys follow a fundamental cycle:
1.  **Extension (P):** We use **P-rotations** (pivoting on the 3rd/7th axis) to leave the tonic and explore relative regions.
2.  **Closure (S):** We use the **S-function** (locking the Root/5th axis) to stabilize the target and finish the journey.

### **6.3 The Tonal Intervention (Harmonic Minor)**
To create a true cadence, the system must introduce a Leading Tone (G#). This creates a conflict: the natural gravity of the lattice does not support this move. The grammar must therefore **reveal** the mechanism of closure.

*   **The Major Disguise (V → I):**
    *   In Major, the Leading Tone resolution (B → C) as T=B → ST=C is **Hidden**.
    *   The natural gravity slide (`s=1`) aligns perfectly with the resolution. The "Snap" is embedded in the fall.
*   **The Minor Revelation (V → i):**
    *   In Minor, the Leading Tone resolution (G# → A) of S is **Revealed** as surface rotation.
    *   The natural gravity is broken by the accidental. The grammar cannot "slide"; it must explicitly **Snap**.
    *   **Grammar:** `M > Sm` (e.g., E → Am).
    *   **Logic:** The **S-rotation** forces the resolution.

### **6.4 The Vector of Resolution: The Conjugate Pairs**

To understand the directional mechanics of the lattice, we must look at the **Geometric Inverses**. Because the lattice is a closed 2-dimensional system (modulo 4 x modulo 3), every forward vector has an exact backward counterpart that restores the system to Identity `(0,0)`.

These pairs reveal why some moves are "Free" (Gravity), some are "Gated" (Modulation), and some are "Forced" (Cadence).

#### **1. The Gravity Pair (1 <-> 3P)**
*   **Forward `1` (The Fall):** `(1, 0)`.
    *   *Mechanism:* Natural gravity. Always admissible.
    *   *Musical Effect:* I -> IV.
*   **Backward `3P` (The Climb):** `(3, 2)`.
    *   *Mechanism:* The geometric inverse of gravity.
    *   *Status:* **Free.** Despite containing the `P` token, this move is geometrically "privileged" as the restoration of the `1` shift. It does not require an unsaturated edge in the same way a modulation does.
    *   *Musical Effect:* **Plagal Motion (IV -> I).** The "Amen" cadence is the restoration of the center against gravity.

#### **2. The Valve Pair (1P <-> 3)**
*   **Forward `1P` (The Drive):** `(1, 2)`.
    *   *Mechanism:* Active Pivot.
    *   *Status:* **Gated (Front Edge).** Blocked by Major (`M`); Allowed by Minor (`m`).
    *   *Musical Effect:* **Dominant Preparation (ii -> V).**
*   **Backward `3` (The Slip):** `(3, 0)`.
    *   *Mechanism:* Passive Slide.
    *   *Status:* **Gated (Back Edge).** Blocked by Minor (`m`); Allowed by Major (`M`).
    *   *Musical Effect:* **Retrogression (V -> ii).**
*   *The Valve:* This asymmetry creates the "Ratchet" effect of tonality. Minor chords drive us forward (`1P`); Major chords let us slip back (`3`).

#### **3. The Snap Pair (1S <-> 3S)**

*   **Forward `1S` (The Authentic Snap):** `(1, 1)`.
    *   *Mechanism:* Gravity + Snap.
    *   *Musical Effect:* **V -> i.**
*   **Backward `3S` (The Neapolitan Snap):** `(3, 1)`.
    *   *Mechanism:* Anti-Gravity + Snap.
    *   *Musical Effect:* **bII -> i.**
*   *Status:* **Forced.** The S-operator is the "Strong Force." It appears symmetrically in both directions to force resolution to the center.

## 7. Geometric Correspondence with Neo-Riemannian Theory (NRT)

Neo-Riemannian Theory has profoundly expanded our understanding of harmony by modeling relationships based on parsimonious voice leading (P, L, R) rather than root motion alone. The **Cholidean Harmony Structure** aligns with this tradition, offering a **topological realization** of these transformations.

By mapping NRT operations onto the surface lattice, we can visualize how "algebraic" transformations correspond to specific spatial movements—either as shifts along the Circle of Fourths or as rotations of the local geometry.

### 7.1 The Correspondence Table
Using **C Major** (M on C-surface) as a reference point, we observe how standard NRT operations map to Cholidean tokens:

| NRT Operation | Transformation | Token Sequence | Geometric Interpretation |
| :--- | :--- | :--- | :--- |
| **L (Leading-Tone)** | C <-> Em | **0m** | **Local Object Selection.** The exchange occurs within the current surface geometry. The C-E dyad is preserved locally. |
| **R (Relative)** | C <-> Am | **m** (via s=1) | **Station Shift.** The relative minor resides on the adjacent surface (F-surface) along the Circle of Fourths, linked by "gravity" (s=1). |
| **P (Parallel)** | C <-> Cm | **0Sm** | **Surface Rotation.** The parallel transformation requires an **S-rotation** to alter the third (E -> Eb) while maintaining the root, effectively "snapping" the geometry to a new mode. |
| **PL (P then L)** | C -> Ab | **0SM** | **Compound Rotation.** A major-third relation generated by applying the S-operator to the Major object. |
| **H (Hexatonic)** | C -> Abm | **Pm** | **Distant Pivot.** A chromatic pole reached by rotating the lattice into a distant sector. |

### 7.2 A Unified View
This mapping suggests that the Cholidean structure and Neo-Riemannian Theory are describing the same harmonic landscape from different vantage points.
*   **NRT** highlights the **voice-leading proximity** between chords.
*   **Cholidean Structure** highlights the **spatial location** of those chords on the Circle-of-Fourths lattice.

For example, the **R** transformation (C <-> Am) is shown here to be a "neighbor" move along the lattice (s=1), while the **P** transformation (C <-> Cm) involves a rotational change in orientation. This geometric distinction offers theorists a new way to visualize the "cost" or "distance" of harmonic travel.

---

## **8. The Manifold Hypothesis: From Graph to Atlas**

In this context, we define a manifold not merely as a topological space characterized by **metric** and **compactness** (as in Euclidean space), but by the existence of **overlapping local maps** (charts). We propose that the 12-Tone Equal Temperament (12ET) system is a **Harmony Manifold**, visualized as an endless 3D strip where local diatonic maps overlap to form a global Atlas.

### **8.1 The Diatonic Scale as a Local Map**
Traditional theory treats a Key as a set of notes. In the 3D visualization, a Key (e.g., C Major / A Natural Minor) appears as a continuous, bounded **3D Strip** of surfaces.

**The C-Major/A-Minor Strip Definition:**
The visual representation of this diatonic set is a composite region spanning four nodes of the lattice:
*   **Half G-Surface (G'):** The notes {G, B, D} are active. (F# is excluded).
*   **Whole C-Surface (C'):** All notes {C, E, G, B} are active.
*   **Whole F-Surface (F'):** All notes {F, A, C, E} are active.
*   **Half Bb-Surface (Bb'):** The notes {D, F, A} are active. (Bb is excluded).

This strip allows for unobstructed navigation via station shifts (`s=1`) within its bounds.

### **8.2 The Theorem of the Unique P-Vector**
To navigate this strip functionally—specifically, to leave the Tonic and return to it—the geometry requires a turning mechanism.

**Theorem:** A Diatonic Scale Map contains exactly **one functional P-Rotation** that allows the progression to close back to the Tonic in a single cycle.

**The Cycle of Closure (I > IV > ii > V > I):**
1.  **Extension (`s=1`):** We move from **I** (C') to **IV** (F') and **ii** (Bb'). This is linear motion away from the center.
2.  **The Pivot Point:** At the **ii** chord (D-F-A on the Bb-Surface), the acoustic state creates an opportunity.
    *   *Saturation Check:* The chord is Minor (`m`). The edge {Bb, D} is **Unsaturated** (Bb is silent).
    *   *Action:* This allows a **P-Rotation** around the **D-Note**.
3.  **The Return (`P`):** The rotation pivots the lattice from the Bb-Surface to the **G-Surface**.
4.  **Resolution:** From the G-Surface (Dominant), gravity (`s=1`) leads naturally back to **C'**.

Without this unique `P` rotation at the supertonic, the strip would be an endless ladder. The `P` operator bends the strip into a loop, creating the sensation of a closed "Key."

### **8.3 The Harmony Atlas**
We can now visualize the 12ET system as the union of these overlapping maps.
*   **Local Map:** A specific strip (e.g., the C-Major/A-Minor Diatonic Set) defined by its unique boundaries.
*   **The Atlas:** The totality of all **12 Diatonic Strips**. Each strip hosts a Relative Major/Minor pair.
*   **Modulation:** The act of sliding the "Window of Visibility" along the endless 3D strip. As we move, the set of available P-rotations changes.

> **Note on Minor Function:** While the strip defines the *Natural* Minor (Aeolian), the *Functional* Minor (Harmonic) requires an additional geometric operation. The single `1P` rotation of the strip produces the Major Dominant (`V`) for the Major Key, but only the Subtonic (`VII`) for the Minor Key. To establish a true Minor Dominant (e.g., E Major in A Minor), the system must execute a secondary rotation (e.g., `iiø7 > V` via `Pd > PM`) to access the leading tone outside the natural strip.

## **9. Conclusion**

The **Cholidean Harmony Structure** proposes a 3D geometric model for tonal analysis, visualizing chords not just as stacks of intervals, but as objects residing on a rotating **Circle-of-Fourths Lattice**.

By defining harmony through spatial tokens—**Station Shifts (s)**, **Pivots (P)**, and **Snaps (S)**—this framework attempts to unify several musical intuitions:

1.  **Diatonic Flow:** Modeled as movement along the lattice (s=1).
2.  **Modulation:** Modeled as the reorientation of the lattice (P).
3.  **Cadence and Chromaticism:** Modeled as the resolution of geometric tension (S).
4.  **The Unity of Systems:** Major (Diatonic), Minor (Modal/Tonal), and Chromatic (Neo-Riemannian) harmonies are not separate languages, but distinct **navigational strategies** on the same geometric surface.

This project does not seek to replace existing theories but to provide a **mnemonic and visual architecture** for them. Whether analyzing a standard Circle-of-Fifths progression or a complex Neo-Riemannian transformation, the Cholidean Surface offers a consistent map for the journey.

---

## **10. Appendix: The Wireframe View (Geometric Correspondence with Tonal Regions)**

While the previous sections describe the navigation of *chords* upon surfaces, the Umbilic-Surface structure also offers a global map of *Tonal Regions* (Keys). By stripping away the surface containers and viewing the lattice as a raw wireframe graph, we observe a strict geometric duality that mirrors Arnold Schoenberg’s "Chart of Regions."

In this macroscopic view, we identify the two primary vectors not as intervals, but as **Axes of Tonality**:

### **10.1 The Major Axis (The `c` Vector)**
The **Curve (`c`)**—the vector connecting a Generator to its Fifth (e.g., G -> C)—represents the **Major Center** (e.g C major chord or scale).
*   **Geometry:** These vectors form the longitudinal rings of the torus (The Circle of Fourths).
*   **Function:** They provide the "Vertical" structural stability of the lattice.
*   **Correspondence:** The 12 `c` vectors map directly to the 12 Major Keys.

### **10.2 The Minor Axis (The `e` Vector)**
The **Edge (`e`)**—the vector connecting the components of the Augmented Triad (e.g., the directed edge B -> G on the G-Triangle)—represents the **Minor Center**.
*   **Geometry:** These vectors form the diagonal spirals that bind the rings together.
*   **Function:** They represent the "Relative" connection.
*   **Correspondence:** The edge B -> G acts as the geometric kernel for **E Minor** (where G-B is the defining minor third). Thus, the 12 `e` vectors map to the 12 Minor Keys.

### **10.3 Resolving the "Schoenberg Shift"**
Traditional 2D theory often struggles to explain the asymmetry between Major and Minor keys. On a flat chart, C Major and A Minor appear as symmetric neighbors.

The 3D Wireframe reveals the topological truth: **They are not symmetric.**
*   To move from **I (C)** to **IV (F)**, one slides along the **Major Axis (`c`)**. This is a smooth flow along the ring.
*   To move from **I (C)** to **vi (Am)**, one must engage the **Minor Axis (`e`)**. This requires a diagonal shift into the spiral grain of the lattice.

This geometric distinction explains the "hesitation" or "shift" often observed in modulation theories (like Schoenberg's). Major and Minor are not merely different colors on the same plane; they are orthogonal vectors in 3D space. The Major Key is a **Ring Segment**; the Minor Key is a **Spiral Segment**.

---
*Document structure and definitions refined with the assistance of Google Gemini 3 Pro.*
