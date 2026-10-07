import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../data/profile_repository.dart';
import '../../domain/sex.dart';

/// Estado editável do formulário de perfil.
class ProfileFormData {
  ProfileFormData([UserProfile? profile])
    : name = TextEditingController(text: profile?.name ?? ''),
      height = TextEditingController(text: decimalToInput(profile?.heightCm)),
      birthDate = profile?.birthDate,
      sex = profile?.sex;

  final TextEditingController name;
  final TextEditingController height;
  DateTime? birthDate;
  Sex? sex;

  ProfileInput toInput() => ProfileInput(
    name: name.text.trim(),
    heightCm: parseDecimal(height.text)!,
    birthDate: birthDate,
    sex: sex,
  );

  void dispose() {
    name.dispose();
    height.dispose();
  }
}

class ProfileFormFields extends StatefulWidget {
  const ProfileFormFields({required this.data, super.key});

  final ProfileFormData data;

  @override
  State<ProfileFormFields> createState() => _ProfileFormFieldsState();
}

class _ProfileFormFieldsState extends State<ProfileFormFields> {
  ProfileFormData get data => widget.data;

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: data.birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Data de nascimento',
    );
    if (picked != null) setState(() => data.birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('profile_name'),
          controller: data.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Nome *'),
          validator: (v) => Validators.required(v, field: 'Nome'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: const Key('profile_height'),
          controller: data.height,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: const InputDecoration(
            labelText: 'Altura *',
            suffixText: 'cm',
          ),
          validator: Validators.height,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _pickBirthDate,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Data de nascimento (opcional)',
              suffixIcon: data.birthDate == null
                  ? const Icon(Icons.calendar_today)
                  : IconButton(
                      tooltip: 'Limpar data',
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => data.birthDate = null),
                    ),
            ),
            child: Text(
              data.birthDate == null
                  ? 'Não informada'
                  : formatDate(data.birthDate!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<Sex?>(
          isExpanded: true,
          initialValue: data.sex,
          decoration: const InputDecoration(labelText: 'Sexo (opcional)'),
          items: [
            const DropdownMenuItem(child: Text('Prefiro não informar')),
            for (final sex in Sex.values)
              DropdownMenuItem(value: sex, child: Text(sex.label)),
          ],
          onChanged: (value) => setState(() => data.sex = value),
        ),
      ],
    );
  }
}
