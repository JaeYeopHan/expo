/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include <ABI43_0_0React/ABI43_0_0renderer/mounting/MountingTransaction.h>

#pragma once

namespace ABI43_0_0facebook {
namespace ABI43_0_0React {

class MountingCoordinator;

/**
 * Generic interface for anything that needs to override specific
 * MountingCoordinator methods. This is for platform-specific escape hatches
 * like animations.
 */
class MountingOverrideDelegate {
 public:
  virtual bool shouldOverridePullTransaction() const = 0;
  virtual ~MountingOverrideDelegate(){};

  /**
   * Delegates that override this method are responsible for:
   *
   * - Returning a MountingTransaction with mutations
   * - Calling
   * - Telemetry, if appropriate
   *
   * @param surfaceId
   * @param number
   * @param mountingCoordinator
   * @return
   */
  virtual better::optional<MountingTransaction> pullTransaction(
      SurfaceId surfaceId,
      MountingTransaction::Number number,
      TransactionTelemetry const &telemetry,
      ShadowViewMutationList mutations) const = 0;
};

} // namespace ABI43_0_0React
} // namespace ABI43_0_0facebook
