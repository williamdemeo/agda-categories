{-# OPTIONS --without-K --safe #-}

open import Level
open import Categories.Category.Core
open import Categories.Category.Cartesian using (Cartesian)
open import Categories.Category.BinaryProducts using (BinaryProducts)
open import Categories.Category.Cocartesian using (Cocartesian)
import Categories.Morphism as M
import Categories.Morphism.Reasoning as MR
import Categories.Morphism.Properties as MP


-- A distributive category is a cartesian, cocartesian category
-- where the canonical distributivity morphism is an iso
-- https://ncatlab.org/nlab/show/distributive+category

module Categories.Category.Distributive {o ℓ e} (𝒞 : Category o ℓ e) where
open Category 𝒞
open M 𝒞
open MR 𝒞
open MP 𝒞
open HomReasoning
open Equiv

record Distributive : Set (levelOfTerm 𝒞) where
  field
    cartesian : Cartesian 𝒞
    cocartesian : Cocartesian 𝒞

  open Cartesian cartesian using (products)
  open BinaryProducts products
  open Cocartesian cocartesian

  distributeˡ : ∀ {A B C : Obj} → A × B + A × C ⇒ A × (B + C)
  distributeˡ = [ id ⁂ i₁ , id ⁂ i₂ ]

  field
    isIsoˡ : ∀ {A B C : Obj} → IsIso (distributeˡ {A} {B} {C})

  -- the dual to the canonical distributivity morphism is then also an iso
  distributeʳ : ∀ {A B C : Obj} →  B × A + C × A ⇒ (B + C) × A
  distributeʳ = [ i₁ ⁂ id , i₂ ⁂ id ]

  isIsoʳ : ∀ {A B C : Obj} →  IsIso (distributeʳ {A} {B} {C})
  isIsoʳ {A} {B} {C} = record 
    { inv = ((swap +₁ swap) ∘ inv) ∘ swap
    ; iso = record 
      { isoˡ = begin 
        (((swap +₁ swap) ∘ inv) ∘ swap) ∘ [ i₁ ⁂ id , i₂ ⁂ id ]                                       ≈⟨ ∘[] ⟩ 
        [ (((swap +₁ swap) ∘ inv) ∘ swap) ∘ (i₁ ⁂ id) , (((swap +₁ swap) ∘ inv) ∘ swap) ∘ (i₂ ⁂ id) ] ≈⟨ []-cong₂ (pullʳ swap∘⁂) (pullʳ swap∘⁂) ⟩
        [ ((swap +₁ swap) ∘ inv) ∘ (id ⁂ i₁) ∘ swap , ((swap +₁ swap) ∘ inv) ∘ (id ⁂ i₂) ∘ swap ]     ≈˘⟨ ∘[] ⟩
        ((swap +₁ swap) ∘ inv) ∘ [ (id ⁂ i₁) ∘ swap , (id ⁂ i₂) ∘ swap ]                              ≈˘⟨ refl⟩∘⟨ []∘+₁ ⟩
        ((swap +₁ swap) ∘ inv) ∘ [ (id ⁂ i₁) , (id ⁂ i₂) ] ∘ (swap +₁ swap)                           ≈⟨ cancelInner isoˡ ⟩
        (swap +₁ swap) ∘ (swap +₁ swap)                                                               ≈⟨ +₁∘+₁ ⟩
        (swap ∘ swap) +₁ (swap ∘ swap)                                                                ≈⟨ +₁-cong₂ swap∘swap swap∘swap ⟩
        (id +₁ id)                                                                                    ≈⟨ +-unique id-comm-sym id-comm-sym ⟩
        id                                                                                            ∎ 
      ; isoʳ = begin 
        [ i₁ ⁂ id , i₂ ⁂ id ] ∘ ((swap +₁ swap) ∘ inv) ∘ swap  ≈⟨ pull-first []∘+₁ ⟩
        [ (i₁ ⁂ id) ∘ swap , (i₂ ⁂ id) ∘ swap ] ∘ inv ∘ swap   ≈˘⟨ []-cong₂ swap∘⁂ swap∘⁂ ⟩∘⟨refl ⟩
        [ swap ∘ (id ⁂ i₁) , swap ∘ (id ⁂ i₂) ] ∘ inv ∘ swap   ≈˘⟨ ∘[] ⟩∘⟨refl ⟩
        (swap ∘ [ (id ⁂ i₁) , (id ⁂ i₂) ]) ∘ inv ∘ swap        ≈⟨ cancelInner isoʳ  ⟩
        swap ∘ swap                                            ≈⟨ swap∘swap ⟩
        id                                                     ∎ 
      } 
    }
    where
      open IsIso (isIsoˡ {A} {B} {C})

  -- the inverse is what one is usually interested in
  distributeˡ⁻¹ : ∀ {A B C : Obj} → A × (B + C) ⇒ A × B + A × C
  distributeˡ⁻¹ = IsIso.inv isIsoˡ
    
  distributeʳ⁻¹ : ∀ {A B C : Obj} → (B + C) × A ⇒ B × A + C × A
  distributeʳ⁻¹ = IsIso.inv isIsoʳ

  -- distribution and injection
  distributeˡ⁻¹-i₁ : ∀ {A B C} → distributeˡ⁻¹ {A} {B} {C} ∘ (id ⁂ i₁) ≈ i₁
  distributeˡ⁻¹-i₁ = (refl⟩∘⟨ (sym inject₁)) ○ (cancelˡ (IsIso.isoˡ isIsoˡ))

  distributeˡ⁻¹-i₂ : ∀ {A B C} → distributeˡ⁻¹ {A} {B} {C} ∘ (id ⁂ i₂) ≈ i₂
  distributeˡ⁻¹-i₂ = (refl⟩∘⟨ (sym inject₂)) ○ (cancelˡ (IsIso.isoˡ isIsoˡ))

  distributeʳ⁻¹-i₁ : ∀ {A B C} → distributeʳ⁻¹ {A} {B} {C} ∘ (i₁ ⁂ id) ≈ i₁
  distributeʳ⁻¹-i₁ = (refl⟩∘⟨ (sym inject₁)) ○ (cancelˡ (IsIso.isoˡ isIsoʳ))

  distributeʳ⁻¹-i₂ : ∀ {A B C} → distributeʳ⁻¹ {A} {B} {C} ∘ (i₂ ⁂ id) ≈ i₂
  distributeʳ⁻¹-i₂ = (refl⟩∘⟨ (sym inject₂)) ○ (cancelˡ (IsIso.isoˡ isIsoʳ))

  -- distribution and projection
  distributeˡ⁻¹-π₁ : ∀ {A B C} → [ π₁ , π₁ ] ∘ distributeˡ⁻¹ {A} {B} {C} ≈ π₁
  distributeˡ⁻¹-π₁ = sym (begin 
    π₁                                                      ≈⟨ introʳ (IsIso.isoʳ isIsoˡ) ⟩ 
    π₁ ∘ distributeˡ ∘ distributeˡ⁻¹                        ≈⟨ pullˡ ∘[] ⟩ 
    ([ π₁ ∘ ((id ⁂ i₁)) , π₁ ∘ (id ⁂ i₂) ] ∘ distributeˡ⁻¹) ≈⟨ (([]-cong₂ (π₁∘⁂ ○ identityˡ) (π₁∘⁂ ○ identityˡ)) ⟩∘⟨refl) ⟩ 
    [ π₁ , π₁ ] ∘ distributeˡ⁻¹                             ∎)

  distributeʳ⁻¹-π₁ : ∀ {A B C} → (π₁ +₁ π₁) ∘ distributeʳ⁻¹ {A} {B} {C} ≈ π₁
  distributeʳ⁻¹-π₁ = sym (begin 
    π₁                                                  ≈⟨ introʳ (IsIso.isoʳ isIsoʳ) ⟩ 
    π₁ ∘ distributeʳ ∘ distributeʳ⁻¹                    ≈⟨ pullˡ ∘[] ⟩ 
    [ π₁ ∘ (i₁ ⁂ id) , π₁ ∘ (i₂ ⁂ id) ] ∘ distributeʳ⁻¹ ≈⟨ (([]-cong₂ π₁∘⁂ π₁∘⁂) ⟩∘⟨refl) ⟩ 
    ((π₁ +₁ π₁) ∘ distributeʳ⁻¹)                        ∎)

  distributeˡ⁻¹-π₂ : ∀ {A B C} → (π₂ +₁ π₂) ∘ distributeˡ⁻¹ {A} {B} {C} ≈ π₂
  distributeˡ⁻¹-π₂ = sym (begin 
    π₂                                                    ≈⟨ introʳ (IsIso.isoʳ isIsoˡ) ⟩ 
    π₂ ∘ distributeˡ ∘ distributeˡ⁻¹                      ≈⟨ pullˡ ∘[] ⟩
    [ π₂ ∘ ((id ⁂ i₁)) , π₂ ∘ (id ⁂ i₂) ] ∘ distributeˡ⁻¹ ≈⟨ ([]-cong₂ π₂∘⁂ π₂∘⁂) ⟩∘⟨refl ⟩
    (π₂ +₁ π₂) ∘ distributeˡ⁻¹                            ∎)

  distributeʳ⁻¹-π₂ : ∀ {A B C} → [ π₂ , π₂ ] ∘ distributeʳ⁻¹ {A} {B} {C} ≈ π₂
  distributeʳ⁻¹-π₂ = sym (begin 
    π₂                                                      ≈⟨ introʳ (IsIso.isoʳ isIsoʳ) ⟩ 
    π₂ ∘ distributeʳ ∘ distributeʳ⁻¹                        ≈⟨ pullˡ ∘[] ⟩ 
    ([ π₂ ∘ ((i₁ ⁂ id)) , π₂ ∘ (i₂ ⁂ id) ] ∘ distributeʳ⁻¹) ≈⟨ (([]-cong₂ (π₂∘⁂ ○ identityˡ) (π₂∘⁂ ○ identityˡ)) ⟩∘⟨refl) ⟩ 
    [ π₂ , π₂ ] ∘ distributeʳ⁻¹                             ∎)

  -- distribute over products
  distributeˡ⁻¹-natural : ∀ {X Y Z U V W} (f : X ⇒ U) (g : Y ⇒ V) (h : Z ⇒ W) → ((f ⁂ g) +₁ (f ⁂ h)) ∘ distributeˡ⁻¹ ≈ distributeˡ⁻¹ ∘ (f ⁂ (g +₁ h))
  distributeˡ⁻¹-natural f g h = begin 
    ((f ⁂ g) +₁ (f ⁂ h)) ∘ distributeˡ⁻¹                                                              ≈⟨ introˡ (IsIso.isoˡ isIsoˡ) ⟩ 
    (distributeˡ⁻¹ ∘ distributeˡ) ∘ ((f ⁂ g) +₁ (f ⁂ h)) ∘ distributeˡ⁻¹                              ≈⟨ pullˡ (pullʳ []∘+₁) ⟩
    (distributeˡ⁻¹ ∘ [(id ⁂ i₁) ∘ (f ⁂ g) , (id ⁂ i₂) ∘ (f ⁂ h)]) ∘ distributeˡ⁻¹                     ≈⟨ (refl⟩∘⟨ ([]-cong₂ ⁂∘⁂ ⁂∘⁂)) ⟩∘⟨refl ⟩
    (distributeˡ⁻¹ ∘ [ id ∘ f ⁂ i₁ ∘ g , id ∘ f ⁂ i₂ ∘ h ]) ∘ distributeˡ⁻¹                           ≈˘⟨ (refl⟩∘⟨ ([]-cong₂ (⁂-cong₂ id-comm +₁∘i₁) (⁂-cong₂ id-comm +₁∘i₂))) ⟩∘⟨refl ⟩
    (distributeˡ⁻¹ ∘ [ f ∘ id ⁂ (g +₁ h) ∘ i₁ , f ∘ id ⁂ (g +₁ h) ∘ i₂ ]) ∘ distributeˡ⁻¹             ≈˘⟨ (refl⟩∘⟨ ([]-cong₂ ⁂∘⁂ ⁂∘⁂)) ⟩∘⟨refl ⟩
    (distributeˡ⁻¹ ∘ [ ((f ⁂ (g +₁ h)) ∘ (id ⁂ i₁)) , ((f ⁂ (g +₁ h)) ∘ (id ⁂ i₂)) ]) ∘ distributeˡ⁻¹ ≈˘⟨ pullˡ (pullʳ ∘[]) ⟩
    (distributeˡ⁻¹ ∘ (f ⁂ (g +₁ h))) ∘ distributeˡ ∘ distributeˡ⁻¹                                    ≈˘⟨ introʳ (IsIso.isoʳ isIsoˡ) ⟩
    distributeˡ⁻¹ ∘ (f ⁂ (g +₁ h))                                                                    ∎

  distributeʳ⁻¹-natural : ∀ {X Y Z U V W} (f : X ⇒ U) (g : Y ⇒ V) (h : Z ⇒ W) → ((g ⁂ f) +₁ (h ⁂ f)) ∘ distributeʳ⁻¹ ≈ distributeʳ⁻¹ ∘ ((g +₁ h) ⁂ f)
  distributeʳ⁻¹-natural f g h = begin
    ((g ⁂ f) +₁ (h ⁂ f)) ∘ distributeʳ⁻¹                                                          ≈⟨ introˡ (IsIso.isoˡ isIsoʳ) ⟩
    (distributeʳ⁻¹ ∘ distributeʳ) ∘ (g ⁂ f +₁ h ⁂ f) ∘ distributeʳ⁻¹                              ≈⟨ pullˡ (pullʳ []∘+₁) ⟩
    (distributeʳ⁻¹ ∘ [ (i₁ ⁂ id) ∘ (g ⁂ f) , (i₂ ⁂ id) ∘ (h ⁂ f) ]) ∘ distributeʳ⁻¹               ≈⟨ (refl⟩∘⟨ ([]-cong₂ ⁂∘⁂ ⁂∘⁂)) ⟩∘⟨refl ⟩
    (distributeʳ⁻¹ ∘ [ (i₁ ∘ g ⁂ id ∘ f) , (i₂ ∘ h ⁂ id ∘ f) ]) ∘ distributeʳ⁻¹                   ≈˘⟨ (refl⟩∘⟨ ([]-cong₂ (⁂-cong₂ +₁∘i₁ id-comm) (⁂-cong₂ +₁∘i₂ id-comm))) ⟩∘⟨refl ⟩
    (distributeʳ⁻¹ ∘ [ ((g +₁ h) ∘ i₁ ⁂ f ∘ id) , ((g +₁ h) ∘ i₂ ⁂ f ∘ id) ]) ∘ distributeʳ⁻¹     ≈˘⟨ (refl⟩∘⟨ ([]-cong₂ ⁂∘⁂ ⁂∘⁂)) ⟩∘⟨refl ⟩
    (distributeʳ⁻¹ ∘ [ ((g +₁ h) ⁂ f) ∘ (i₁ ⁂ id) , ((g +₁ h) ⁂ f) ∘ (i₂ ⁂ id) ]) ∘ distributeʳ⁻¹ ≈˘⟨ pullˡ (pullʳ ∘[]) ⟩
    (distributeʳ⁻¹ ∘ ((g +₁ h) ⁂ f)) ∘ distributeʳ ∘ distributeʳ⁻¹                                ≈˘⟨ introʳ (IsIso.isoʳ isIsoʳ) ⟩
    distributeʳ⁻¹ ∘ ((g +₁ h) ⁂ f)                                                                ∎

  -- distribute and swap
  distributeˡ⁻¹∘swap : ∀ {A B C : Obj} → distributeˡ⁻¹ ∘ swap ≈ (swap +₁ swap) ∘ distributeʳ⁻¹ {A} {B} {C}
  distributeˡ⁻¹∘swap = Iso⇒Mono (IsIso.iso isIsoˡ) (distributeˡ⁻¹ ∘ swap) ((swap +₁ swap) ∘ distributeʳ⁻¹) (begin 
    (distributeˡ ∘ distributeˡ⁻¹ ∘ swap)                    ≈⟨ cancelˡ (IsIso.isoʳ isIsoˡ) ⟩
    swap                                                    ≈˘⟨ cancelʳ (IsIso.isoʳ isIsoʳ) ⟩ 
    ((swap ∘ distributeʳ) ∘ distributeʳ⁻¹)                  ≈⟨ ∘[] ⟩∘⟨refl ⟩ 
    [ swap ∘ (i₁ ⁂ id) , swap ∘ (i₂ ⁂ id) ] ∘ distributeʳ⁻¹ ≈˘⟨ []-cong₂ (sym swap∘⁂) (sym swap∘⁂) ⟩∘⟨refl ⟩ 
    [ (id ⁂ i₁) ∘ swap , (id ⁂ i₂) ∘ swap ] ∘ distributeʳ⁻¹ ≈˘⟨ pullˡ []∘+₁ ⟩ 
    distributeˡ ∘ (swap +₁ swap) ∘ distributeʳ⁻¹            ∎)

  distributeʳ⁻¹∘swap : ∀ {A B C : Obj} → distributeʳ⁻¹ ∘ swap ≈ (swap +₁ swap) ∘ distributeˡ⁻¹ {A} {B} {C}
  distributeʳ⁻¹∘swap = Iso⇒Mono (IsIso.iso isIsoʳ) (distributeʳ⁻¹ ∘ swap) ((swap +₁ swap) ∘ distributeˡ⁻¹) (begin 
    (distributeʳ ∘ distributeʳ⁻¹ ∘ swap)                    ≈⟨ cancelˡ (IsIso.isoʳ isIsoʳ) ⟩ 
    swap                                                    ≈˘⟨ cancelʳ (IsIso.isoʳ isIsoˡ) ⟩ 
    ((swap ∘ distributeˡ) ∘ distributeˡ⁻¹)                  ≈⟨ (∘[] ⟩∘⟨refl) ⟩ 
    [ swap ∘ (id ⁂ i₁) , swap ∘ (id ⁂ i₂) ] ∘ distributeˡ⁻¹ ≈˘⟨ ([]-cong₂ (sym swap∘⁂) (sym swap∘⁂)) ⟩∘⟨refl ⟩ 
    [ (i₁ ⁂ id) ∘ swap , (i₂ ⁂ id) ∘ swap ] ∘ distributeˡ⁻¹ ≈˘⟨ pullˡ []∘+₁ ⟩ 
    (distributeʳ ∘ (swap +₁ swap) ∘ distributeˡ⁻¹)          ∎)
