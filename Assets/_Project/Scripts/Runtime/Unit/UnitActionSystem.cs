using System;
using UnityEngine;
using UnityEngine.EventSystems;

public class UnitActionSystem : Singleton<UnitActionSystem>
{
   public event EventHandler OnSelectedUnitchanged;

   [SerializeField]
   private Unit selectedUnit;
   [SerializeField]
   private LayerMask unitLayerMask;

   private BaseAction selectedAction;
   private bool isBusy;

   private void Start()
   {
      SetSelectedUnit(selectedUnit);
   }

   private void Update()
   {
      if (isBusy) return;

      if (EventSystem.current.IsPointerOverGameObject()) return;

      if (TryHandleUnitSelection()) return;

      HandleSelectedAction();
   }

   private void HandleSelectedAction()
   {
      if (Input.GetMouseButtonDown(0))
      {
         GridPosition mouseGridPosition =
            LevelGrid.Instance.GetGridPosition(MouseWorld.GetPosition());

         if (selectedAction.IsValidActionGridPosition(mouseGridPosition))
         {
            selectedAction.TakeAction(mouseGridPosition, ClearBusy);
         }
      }
   }

   private void SetBusy()
   {
      isBusy = true;
   }

   private void ClearBusy()
   {
      isBusy = false;
   }

   private bool TryHandleUnitSelection()
   {
      if (Input.GetMouseButtonDown(0))
      {
         Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
         bool hasHit = Physics.Raycast(ray, out RaycastHit hitInfo, float.MaxValue, unitLayerMask);

         if (hasHit)
         {
            if (hitInfo.transform.TryGetComponent(out Unit unit))
            {
               if (unit == selectedUnit) return false;
               SetSelectedUnit(unit);
               return true;
            }
         }
      }
      
      return false;
   }

   private void SetSelectedUnit(Unit unit)
   {
      selectedUnit = unit;

      SetSelectedAction(unit.GetMoveAction());

      OnSelectedUnitchanged?.Invoke(this, EventArgs.Empty);
   }

   public void SetSelectedAction(BaseAction baseAction)
   {
      selectedAction = baseAction;
   }

   public Unit GetSelectedUnit()
   {
      return selectedUnit;
   }

   public BaseAction GetSelectedAction()
   {
      return selectedAction;
   }
}
