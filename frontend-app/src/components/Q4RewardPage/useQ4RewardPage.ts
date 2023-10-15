/**********************************************************************
 *
 *   Component hook generated by Quest
 *
 *   Code Logic for the component goes in this hook
 *   To setup bindings that use the data here or call the functions here, use the Quest editor
 *   Do not change the name of the hook
 *
 *   For help and further details refer to: https://www.quest.ai/docs
 *
 *
 **********************************************************************/

import React, { useEffect } from "react";
import useQ4RewardPageResponsiveSize from "./useQ4RewardPageResponsiveSize";
import { useParams, useNavigate } from "react-router-dom";
import { CardDetails, Reward } from "src/api/types";
import { useAuthContext } from "@asgardeo/auth-react";
import { getCardDetails, getRewardDetails } from "src/api/api";

/* These are the possible values for the current variant. Use this to change the currentVariant dynamically.
Please don't modify */
const variantOptions = {
  ScreenDesktop: "ScreenDesktop",
  ScreenMobile: "ScreenMobile",
};

const useQ4RewardPage = () => {
  const navigate = useNavigate();
  const [currentVariant, setCurrentVariant] = React.useState<string>(
    variantOptions["ScreenDesktop"]
  );

  const { rewardId } = useParams();
  const [isRewardLoading, setIsRewardLoading] = React.useState(false);
  const [reward, setReward] = React.useState<Reward | null>(null);
  const [isCardDetailsLoading, setIsCardDetailsLoading] = React.useState(false);
  const [cardDetails, setCardDetails] = React.useState<CardDetails | null>(
    null
  );
  const [isAgreementChecked, setIsAgreementChecked] = React.useState(false);

  const { state } = useAuthContext();

  const getRewardImage = (rewardName: string) => {
    switch (rewardName) {
      case "Target":
        return "/images/target.png";
      case "Starbucks Coffee":
        return "/images/starbucks.png";
      case "Jumba Juice":
        return "/images/jamba.png";
      case "Grubhub":
        return "/images/grubhub.png";
      default:
        return "";
    }
  };

  async function getRewardInfo() {
    if (rewardId) {
      setIsRewardLoading(true);
      getRewardDetails(parseInt(rewardId))
        .then((res) => {
          const logoUrl = getRewardImage(res.data.name);
          setReward({ ...res.data, logoUrl });
        })
        .catch((e) => {
          console.log(e);
        })
        .finally(() => {
          setIsRewardLoading(false);
        });
    }
  }

  async function getCardInfo(userId) {
    setIsCardDetailsLoading(true);
    getCardDetails(userId)
      .then((res) => {
        setCardDetails(res.data);
      })
      .catch((e) => {
        console.log(e);
      })
      .finally(() => {
        setIsCardDetailsLoading(false);
      });
  }

  useEffect(() => {
    if (state.isAuthenticated && state.sub) {
      getCardInfo(state.sub);
      getRewardInfo();
    }
  }, [state]);

  const handleRedeemClick = (param1) => {
    navigate(`/qr-code/${param1}`);
  };
  const breakpointsVariant = useQ4RewardPageResponsiveSize();

  React.useEffect(() => {
    if (breakpointsVariant !== currentVariant) {
      setCurrentVariant(breakpointsVariant);
    }
  }, [breakpointsVariant]);

  React.useEffect(() => {
    if (breakpointsVariant !== currentVariant) {
      setCurrentVariant(breakpointsVariant);
    }
  }, [breakpointsVariant]);

  const data: any = {
    currentVariant,
    reward,
    isRewardLoading,
    cardDetails,
    isCardDetailsLoading,
    isAgreementChecked,
  };

  const fns: any = {
    setCurrentVariant,
    handleRedeemClick,
    setIsAgreementChecked,
  };

  return { data, fns };
};

export default useQ4RewardPage;
