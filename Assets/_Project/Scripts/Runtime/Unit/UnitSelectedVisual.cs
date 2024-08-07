using System;
using UnityEngine;
using UnityEngine.UI;

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
      UnitActionSystem.Instance.OnSelectedUnitchange += UnitActionSystem_OnSelectedUnitChange;
      UpdateVisual();
   }

   private void UnitActionSystem_OnSelectedUnitChange(object sender, EventArgs e)
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
         canvasGroup.alpha = 0f;
      }
   }
}
