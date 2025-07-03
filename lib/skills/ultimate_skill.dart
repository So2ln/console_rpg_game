import 'skill_base.dart';

class UltimateSkill extends SkillBase {
  @override
  final String name;
  @override
  final String description;
  @override
  final String? debuffType;
  @override
  final int? debuffValue;

  UltimateSkill(
    this.name,
    this.description, {
    this.debuffType,
    this.debuffValue,
  });
}
