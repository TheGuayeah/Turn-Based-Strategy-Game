using System;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(MeshRenderer))]
public class UnitSelectedVisual : MonoBehaviour
{
   [SerializeField]
   private Unit unit;
   
   private Image image;

   private void Awake()
   {
      image = GetComponent<Image>();
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
         image.enabled = true;
      }
      else
      {
         image.enabled = false;
      }
   }
}
