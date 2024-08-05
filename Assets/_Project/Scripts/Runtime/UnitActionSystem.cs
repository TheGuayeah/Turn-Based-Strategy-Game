using System;
using UnityEngine;

public class UnitActionSystem : Singleton<UnitActionSystem>
{
   public event EventHandler OnSelectedUnitchange;

   [SerializeField]
   private Unit selectedUnit;
   [SerializeField]
   private LayerMask unitLayerMask;

   private void Update()
   {
      if (Input.GetMouseButtonDown(0))
      {
         if (TryHandleUnitSelection()) return;
         selectedUnit.Move(MouseWorld.GetPosition());
      }
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
      OnSelectedUnitchange?.Invoke(this, EventArgs.Empty);
   }

   public Unit GetSelectedUnit()
   {
      return selectedUnit;
   }
}
