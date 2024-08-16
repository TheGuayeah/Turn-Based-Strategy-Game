using System;
using UnityEngine;

[RequireComponent(typeof(CanvasGroup))]
public class UnitSelectedVisual : MonoBehaviour
{
   [SerializeField]
   private Unit unit;
   
   private CanvasGroup canvasGroup;

   private void Awake()
   {
      canvasGroup = GetComponent<CanvasGroup>();
   }

   private void Start()
   {
      UnitActionSystem.Instance.OnSelectedUnitChanged += UnitActionSystem_OnSelectedUnitChange;
      unit.OnMouseOverUnitChanged += Unit_OnMouseOverUnitChanged;
      UpdateVisual();
   }

   private void UnitActionSystem_OnSelectedUnitChange(object sender, EventArgs e)
   {
      UpdateVisual();
   }

   private void Unit_OnMouseOverUnitChanged(object sender, EventArgs e)
   {
      UpdateVisual();
   }

   private void UpdateVisual()
   {
      if (UnitActionSystem.Instance.GetSelectedUnit() == unit)
      {
         canvasGroup.alpha = 1f;
      }
      else
      {
         if (unit.IsMouseOver()) canvasGroup.alpha = 1f;
         else canvasGroup.alpha = 0f;
      }
   }

   private void OnDestroy()
   {
      UnitActionSystem.Instance.OnSelectedUnitChanged -= UnitActionSystem_OnSelectedUnitChange;
   }
}
