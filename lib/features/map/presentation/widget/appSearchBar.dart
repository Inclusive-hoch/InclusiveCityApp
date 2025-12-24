import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inclusivecity_frontend/features/map/presentation/bloc/place_bloc.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({super.key});

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // ✅ Ahora SÍ funciona: context es válido aquí
      context.read<PlacesBloc>().add(ClearSearchEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      builder: (context, state) {
        if (state is PlacesInitial && _controller.text.isNotEmpty) {
          _controller.clear();
        }

        return Card(
          margin: const EdgeInsets.all(12.0),
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: "¿Adónde vas?",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: (state is PlacesLoading)
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      ),
                    )
                  : (state is! PlacesInitial)
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _focusNode.unfocus();
                            context.read<PlacesBloc>().add(ClearSearchEvent());
                          },
                        )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 14.0,
              ),
            ),
            onChanged: (query) {
              context.read<PlacesBloc>().add(SearchPlacesEvent(query));
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }
}