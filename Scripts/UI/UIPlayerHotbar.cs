using Godot;

[GlobalClass]
public partial class UIPlayerHotbar : UIInventory, IUIElement
{
	private Player _player;
	[Export] private InputEventAction _inputEventAction;
	[Export] private bool _isActiveOnStart;

	public InputEventAction InputEventAction => _inputEventAction;
	public bool IsActiveOnStart => _isActiveOnStart;

	public override void _Ready()
	{
		base._Ready();
		_player = ReferenceCenter.Player;
		SetInventoryData(_player.FindChild("Hotbar") as InventorySystem);
	}

	public override void _Process(double delta)
	{
		base._Process(delta);
	}

	public override void _Input(InputEvent @event)
	{
		if (@event.IsActionPressed("action1"))
		{
			Item item = GetSlot(0).Item;
			if (item.ItemData is IAction action)
			{
				action.Action(item, _player, _player.GetGlobalMousePosition());
			}
		}

		if (@event.IsActionPressed("action2"))
		{
			Item item = GetSlot(1).Item;
			if (item.ItemData is ISecondaryAction secondaryAction)
			{
				secondaryAction.SecondaryAction(item, _player, _player.GetGlobalMousePosition());
			}
		}
	}

	public void Close()
	{
		Visible = false;
	}

	public void Open()
	{
		Visible = true;
	}
}
