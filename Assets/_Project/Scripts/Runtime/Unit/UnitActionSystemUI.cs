using System;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class UnitActionSystemUI : MonoBehaviour
{
   [SerializeField]
   private Transform actionBtnPrefab;
   [SerializeField]
   private Transform actionBtnContainer;
   [SerializeField]
   private TextMeshProUGUI actionPointsText;

   private List<ActionButtonUI> actionButtons;

   private void Awake()
   {
      actionButtons = new List<ActionButtonUI>();
   }

   private void Start()
   {
      UnitActionSystem.Instance.OnSelectedUnitChanged += UnitActionSystem_OnSelectedUnitChanged;
      UnitActionSystem.Instance.OnSelectedActionChanged += UnitActionSystem_OnSelectedActionChanged;
      UnitActionSystem.Instance.OnActionStarted += UnitActionSystem_OnActionStarted;
      TurnSystem.Instance.OnTurnChanged += TurnSystem_OnTurnChanged;
      Unit.OnAnyAcionPointsChanged += Unit_OnAnyAcionPointsChanged;

      UpdateActionPoints();
      CreateUnitActionButtons();
      UpdateSelectedVisual();
   }

   private void CreateUnitActionButtons()
   {
      foreach (Transform button in actionBtnContainer)
      {
         Destroy(button.gameObject);
      }

      actionButtons.Clear();

      Unit selectedUnit = UnitActionSystem.Instance.GetSelectedUnit();

      foreach (BaseAction action in selectedUnit.GetBaseActions())
      {
         Transform button = Instantiate(actionBtnPrefab, actionBtnContainer);
         ActionButtonUI actionButtonUI = button.GetComponent<ActionButtonUI>();
         actionButtonUI.SetBaseAction(action);

         actionButtons.Add(actionButtonUI);
      }
   }

   private void UnitActionSystem_OnSelectedUnitChanged(object sender, EventArgs e)
   {
      UpdateActionPoints();
      CreateUnitActionButtons();
      UpdateSelectedVisual();
   }

   private void UnitActionSystem_OnSelectedActionChanged(object sender, EventArgs e)
   {
      UpdateSelectedVisual();
   }

   private void UnitActionSystem_OnActionStarted(object sender, EventArgs e)
   {
      UpdateActionPoints();
   }

   private void UpdateSelectedVisual()
   {
      foreach (ActionButtonUI button in actionButtons)
      {
         button.UpdateSelectedVisual();
      }
   }

   private void UpdateActionPoints()
   {
      Unit selectedUnit = UnitActionSystem.Instance.GetSelectedUnit();
      actionPointsText.text = $"Action Points: {selectedUnit.GetActionPoints()}";
   }

   private void TurnSystem_OnTurnChanged(object sender, EventArgs e)
   {
      UpdateActionPoints();
   }

   private void Unit_OnAnyAcionPointsChanged(object sender, EventArgs e)
   {
      UpdateActionPoints();
   }
}
