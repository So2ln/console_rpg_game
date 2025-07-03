import 'skill_base.dart';

class NormalSkill extends SkillBase {
  @override
  final String name;
  @override
  final String description;
  @override
  final String? debuffType;
  @override
  final int? debuffValue;

  NormalSkill(this.name, this.description, {this.debuffType, this.debuffValue});
}
