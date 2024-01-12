import '../Configurations/constants.dart';
import 'core.dart';

/// Power Cell Container
class PowerCell{
  int _realValue = Const.nullCell;
  int _observed = Const.nullCell;
  int _resultValue = Const.nullCell;

  Spell? _spell;

  PowerCell();

  int get value => _realValue;
  int get observedVal => _observed;
  int get resultVal => _resultValue;

  Spell? get spell => _spell;


  set value(int newVal) {
    _realValue = newVal;
    updateValues();

  }

  set spell(Spell? newSpell){
    _spell = newSpell;
    updateValues();
  }

  decrementSpell(int playerState){
    if (spell != null){
      if (spell!.from == playerState){
        if (spell!.duration <= 1) {
          spell = null;
          updateValues();
        } else {
          spell!.duration--;
        }
      }
    }else{
      _observed = _realValue;
      _resultValue = _realValue;
    }
  }


  updateValues(){

    if (spell == null){
      _observed = _realValue;
      _resultValue = _observed;
    }else{
      spellChangedValues();
    }
  }

  spellChangedValues(){
    switch(spell!.effect){

      case CellEffect.protected:
        _observed = value;
        _resultValue = _observed;
        break;
      case CellEffect.swapped:
        _observed = (1-_realValue);
        _resultValue = _observed;
        break;
      case CellEffect.quantum:
        _observed = Const.qCell;
        _resultValue = _observed;
        break;
      case CellEffect.empty:
      // TODO: Handle this case.
      case CellEffect.hidden:
        _observed = Const.nullCell;
        _resultValue = _realValue;
        break;
      case CellEffect.hiddenTrap:
        _observed = Const.nullCell;
        _resultValue = _realValue;
        break;
      case CellEffect.trap:
        _observed = value;
        _resultValue = _observed;
        break;
      case CellEffect.trapped:
      // TODO: Handle this case.
        _resultValue = _realValue;
        break;
      case CellEffect.extraCell:
        _observed = spell!.from;
        _resultValue = _observed;
        break;
      case CellEffect.decoy:
        _observed = spell!.from;
        _resultValue = Const.nullCell;
    }
  }

  factory PowerCell.create({required int value, Spell? spell}){
    PowerCell cell = PowerCell();
    cell._realValue = value;
    cell.spell = spell;
    return cell;
  }
}