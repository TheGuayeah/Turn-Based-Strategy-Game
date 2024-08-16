using UnityEngine;
using UnityEngine.UI;

public class UnitWorldUI : MonoBehaviour
{
	[SerializeField]
	private Unit unit;
	[SerializeField]
	private Image healthBarImage;
	[SerializeField]
	private HealthSystem healthSystem;
   [SerializeField]
   private Material fullHealthColor;
   [SerializeField]
   private Material halfHealthColor;
   [SerializeField]
   private Material lowHealthColor;

   private void Start()
   {
      healthSystem.OnTakeDamage += HealthSystem_OnTakeDamage;
      UpdateHealthBar();
	}

   private void HealthSystem_OnTakeDamage(object sender, System.EventArgs e)
   {
      UpdateHealthBar();
   }

   private void UpdateHealthBar()
   {
      healthBarImage.fillAmount = healthSystem.GetHealthNormalized();
   }

   private void SetHealthColor()
   {
      if (TryGetUnit(out Unit unit))
      {
         if (unit.IsEnemy()) return;
      }
      if (healthSystem.GetHealthNormalized() >= (1f / 3) * 2)
      {
         healthBarImage.material = fullHealthColor;
      }
      else if (healthSystem.GetHealthNormalized() >= 1f / 3)
      {
         healthBarImage.material = halfHealthColor;
      }
      else
      {
         healthBarImage.material = lowHealthColor;
      }
   }

   private bool TryGetUnit(out Unit unit)
   {
      unit = GetComponent<Unit>();
      return unit != null;
   }
}