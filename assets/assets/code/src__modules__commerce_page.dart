// COMMERCE — product grid, detail sheet, cart state.
//
// TECHNIQUES ON DISPLAY
// ---------------------
// • Responsive grid (SliverGridDelegateWithMaxCrossAxisExtent adapts
//   column count to width — no manual breakpoint math for columns)
// • Modal bottom sheet for product detail (mobile-first pattern that
//   also looks right centred on web)
// • Riverpod cart state shared with the header badge: toggling in the
//   sheet instantly updates the badge with zero callbacks.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/state.dart';
import '../core/code_view.dart';
import '../core/data.dart';
import '../core/tokens.dart';
import '../core/widgets.dart';

class CommercePage extends ConsumerWidget {
  const CommercePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: MaxWidth(
        child: Padding(
          padding: const EdgeInsets.all(Tokens.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionHeader(
                eyebrow: 'Commerce',
                title: 'Maison Prism',
                subtitle:
                    'A mini storefront. Tap a product for the detail sheet.',
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CodeAction(
                        assetPath:
                            'assets/code/src__modules__commerce_page.dart'),
                    _CartBadge(count: cart.length, onClear: () {
                      ref.read(cartProvider.notifier).clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Cart cleared')),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.s16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // MaxCrossAxisExtent: column count derives from width, so
                // no manual breakpoint math. shrinkWrap + never-scrollable
                // nests the grid inside the page scroll instead of fighting
                // it (nested scrollables steal gestures from each other).
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: Tokens.s16,
                  crossAxisSpacing: Tokens.s16,
                  mainAxisExtent: 250,
                ),
                itemCount: kProducts.length,
                itemBuilder: (context, i) => _ProductCard(
                  product: kProducts[i],
                  index: i,
                  inCart: cart.contains(kProducts[i].id),
                )
                    .animate()
                    .fadeIn(delay: (i * 60).ms, duration: 400.ms)
                    .slideY(begin: 0.12, end: 0),
              ),
              const SizedBox(height: Tokens.s16),
              GlassCard(
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: Tokens.s12),
                    Expanded(
                      child: Text(
                        cart.isEmpty
                            ? 'Cart is empty — add something to see Riverpod state update the badge above.'
                            : '${cart.length} item${cart.length == 1 ? '' : 's'} in cart · \$${_total(cart).toStringAsFixed(2)} total. State lives in cartProvider (app/state.dart).',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Tokens.s32),
            ],
          ),
        ),
      ),
    );
  }

  double _total(Set<String> cart) => kProducts
      .where((p) => cart.contains(p.id))
      .fold(0.0, (sum, p) => sum + p.price);
}

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count, required this.onClear});
  final int count;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Badge(
          label: Text('$count'),
          isLabelVisible: true,
          child: const Icon(Icons.shopping_bag_outlined),
        ),
        if (count > 0)
          TextButton(onPressed: onClear, child: const Text('Clear')),
      ],
    ).animate(target: count.toDouble()).scale(
        begin: const Offset(1, 1),
        end: const Offset(1.15, 1.15),
        duration: 150.ms); // badge pops whenever the count changes
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard(
      {required this.product, required this.index, required this.inCart});
  final Product product;
  final int index;
  final bool inCart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(Tokens.r16),
      onTap: () => _showDetail(context, ref),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: product.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Tokens.r16)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(product.icon,
                          size: 56,
                          color: Colors.white.withValues(alpha: 0.92)),
                    ),
                    Positioned(
                      top: Tokens.s8,
                      left: Tokens.s8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Tokens.s8, vertical: Tokens.s4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(product.tag,
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Tokens.s12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800)),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Color(0xFFD9930D)),
                            const SizedBox(width: 4),
                            Text('${product.rating}',
                                style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text('\$${product.price.toStringAsFixed(0)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(Tokens.r24)),
      ),
      builder: (context) => _DetailSheet(product: product),
    );
  }
}

class _DetailSheet extends ConsumerWidget {
  const _DetailSheet({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(cartProvider).contains(product.id);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Tokens.s24, Tokens.s8, Tokens.s24, Tokens.s32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: product.colors),
              borderRadius: BorderRadius.circular(Tokens.r16),
            ),
            child: Center(
                child: Icon(product.icon,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.92))),
          ),
          const SizedBox(height: Tokens.s16),
          Row(
            children: [
              Expanded(
                child: Text(product.name,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900)),
              ),
              Text('\$${product.price.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary)),
            ],
          ),
          const SizedBox(height: Tokens.s4),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Color(0xFFD9930D)),
              const SizedBox(width: 4),
              Text('${product.rating} · 2.3k reviews · ${product.tag}'),
            ],
          ),
          const SizedBox(height: Tokens.s12),
          Text(
            'Free shipping over \$75 · 30-day returns · 2-year warranty. '
            'This sheet is a showModalBottomSheet with showDragHandle — '
            'the same pattern used by real storefront apps.',
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: Tokens.s16),
          FilledButton.icon(
            onPressed: () {
              ref.read(cartProvider.notifier).toggle(product.id);
              Navigator.pop(context);
            },
            icon: Icon(inCart
                ? Icons.remove_shopping_cart_outlined
                : Icons.add_shopping_cart_outlined),
            label: Text(inCart
                ? 'Remove from cart'
                : 'Add to cart — \$${product.price.toStringAsFixed(0)}'),
          ),
        ],
      ),
    );
  }
}
