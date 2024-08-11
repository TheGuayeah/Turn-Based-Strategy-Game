using System;
using UnityEngine;
using UnityEngine.UI;

public class UnitActionSystemUI : MonoBehaviour
{
   [SerializeField]
   private Transform actionBtnPrefab;
   [SerializeField]
   private Transform actionBtnContainer;

   private void Start()
   {
      UnitActionSystem.Instance.OnSelectedUnitchanged += UnitActionSystem_OnSelectedUnitChanged;
      CreateUnitActionButtons();
   }

   private void CreateUnitActionButtons()
   {
      foreach (Transform button in actionBtnContainer)
      {
         Destroy(button.gameObject);
      }

      Unit selectedUnit = UnitActionSystem.Instance.GetSelectedUnit();

      foreach (BaseAction action in selectedUnit.GetBaseActions())
      {
         Transform button = Instantiate(actionBtnPrefab, actionBtnContainer);
         ActionButtonUI actionButtonUI = button.GetComponent<ActionButtonUI>();
         actionButtonUI.SetBaseAction(action);
      }
   }

   private void UnitActionSystem_OnSelectedUnitChanged(object sender, EventArgs e)
   {
      CreateUnitActionButtons();
   }
}
