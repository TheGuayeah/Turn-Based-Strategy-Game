using System;
using UnityEngine;

public class UnitActionSystem : Singleton<UnitActionSystem>
{
   public event EventHandler OnSelectedUnitchanged;

   [SerializeField]
   private Unit selectedUnit;
   [SerializeField]
   private LayerMask unitLayerMask;

   private bool isBusy;

   private void Update()
   {
      if (isBusy) return;

      if (Input.GetMouseButtonDown(0))
      {
         if (TryHandleUnitSelection()) return;

         GridPosition mouseGridPosition = 
            LevelGrid.Instance.GetGridPosition(MouseWorld.GetPosition());

         if (selectedUnit.GetMoveAction().IsValidActionGridPosition(mouseGridPosition))
         {
            SetBusy();
            selectedUnit.GetMoveAction().Move(mouseGridPosition, ClearBusy);
         }
      }
      if (Input.GetMouseButtonDown(1))
      {
         SetBusy();
         selectedUnit.GetSpinAction().Spin(ClearBusy);
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
      Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
      bool hasHit = Physics.Raycast(ray, out RaycastHit hitInfo, float.MaxValue, unitLayerMask);

      if (hasHit)
      {
         if (hitInfo.transform.TryGetComponent(out Unit unit))
         {
            SetSelectedUnit(unit);
            return true;
         }
      }
      return false;
   }

   private void SetSelectedUnit(Unit unit)
   {
      selectedUnit = unit;
      OnSelectedUnitchanged?.Invoke(this, EventArgs.Empty);
   }

   public Unit GetSelectedUnit()
   {
      return selectedUnit;
   }
}
